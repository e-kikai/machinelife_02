#! ruby -Ku
#
# クローラクラスベースのソースファイル
# Author::    川端洋平
# Date::      2012/5/17
# Copyright:: Copyright (c) 2012 川端洋平
#
require 'rubygems'
require 'mechanize'
require 'kconv'
require 'nkf'
require 'uri'
require 'logger'
require 'zlib'
require 'mail'

require File.dirname(__FILE__) + '/../lib/my_string'

# クローラクラス
class Base
  #### インスタンス変数アクセッサ ####
  attr_reader   :d, :company, :company_id, :rex, :tarray
  attr_accessor :depth, :log, :ex, :update

  LATER_CAP = { 9 => 1500, 8 => 1200, 7 => 1000, 6 => 800, 5 => 600, 4 => 360, 3 => 240, }

  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    mechanize_init # Mechinizeの初期化

    @company    = 'xxxxxx'
    @company_id = 99999
    @start_uri  = 'http://aaaaa'

    @d      = [] # スクレイピング結果の格納
    @q      = [] # クロールURIキュー
    @v      = [] # 履歴URI配列

    @ex     = [] # 既存情報(ID)一覧
    @rex    = [] # 現存情報(ID)一覧

    @depth  = 20 # クロール深度
    @retnum = 3  # getリトライ回数
    @retslp = 20 # リトライ時スリープ秒
    @log    = Logger.new(STDERR)

    @crawl_allow = /stock\.php\?maxRowID=5&pageNum=[0-9]+$/
    @crawl_deny  = nil

    @temp   = ''
    @tarray = []

    # メール送信用エラーログ
    @error = []

    @update = false
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'#TableList tbody tr').each do |m|
      next if m%'th'

      #### 既存情報の場合スキップ ####
      uid = (m%'td:nth(3)').text.f
      if @ex.include?(uid)
        @rex << uid
        @log.debug("exsist:#{uid}")
        # next if @update == false
      end

      temp = {
        uid:,
        no: (m%'td:nth(4)').text.f,
        name: (m%'td:nth(5)').text.f,
        maker: (m%'td:nth(6)').text.f,
        model: (m%'td:nth(8)').text.f,
        year: (m%'td:nth(7)').text.f,
        spec: ''
      }
      temp[:hint] = temp[:name].gsub(/\((.*?)\)$/, '')

      #### ディープクロール ####
      detail_uri = join_uri(@p.uri, m.%('td:nth(3) a')[:href])
      p2 = nokogiri(detail_uri)

      (p2/'table.spec th').each do |n|
        ntext  = n.text.f
        nntext = n.next_element.text.f
        if ntext == '保管'
          temp[:location] = nntext
        elsif ntext == '管理状況'
          temp[:comment] = nntext
        elsif /^(在庫No|問合せ)$/ !~ ntext
          if nntext != ''
            temp[:spec] += "#{ntext}:#{nntext}、"
          end
        end
      end

      # 画像
      temp[:used_imgs] = []
      (p2/'img.DetailPhoto').each do |i|
        temp[:used_imgs] << join_uri(@p.uri, i[:src])
      end

      @d << temp
      @log.debug(temp)
    end

    self
  rescue StandardError => e
    @log.error("scrape error : #{e}\n".toutf8 + $@.join("\n"))
    raise "scrape error"
  end

  #
  # 2次クロール（セーフレベル2内で処理）
  # Param:: String uri 2次クロールするURI
  #
  def nokogiri(uri)
    page = NKF.nkf("-wZX--cp932", URI.parse(Addressable::URI.parse(uri).normalize.to_s).read)
    Nokogiri::HTML(page, nil, 'UTF-8')
  end

  #
  # ページの取得
  # Param:: String uri 取得するURI
  # Return:: self
  #
  def getpage(uri, retcount = @retnum)
    @p = @a.get(uri)
    self
  rescue StandardError
    if (retcount -= 1).positive?
      sleep @retslp
      @log.warn("retry #{retcount} : #{uri}")
      mechanize_init
      retry
    else
      raise
    end
  end

  #
  # クロールメソッド
  # Param:: String url クロール開始URL
  # Param:: Integer depth 初期クロール深度
  # Return:: self
  #
  def crawl
    # クロールキューにスタートURIを追加
    @q << [@start_uri, 1]

    #### クロールループ ####
    loop do
      break if @q.length < 1

      uri, de = @q.shift
      @log.info("#{de} -> #{uri}")

      begin
        getpage(uri) # ページの取得
        scrape       # スクレイピング

        # クロール深度チェック
        append_quere(de + 1) if de < @depth
      rescue StandardError => e
        error_report("getpage error", e)
      end
    end

    # エラーログをメールで送信(あれば)
    send_error

    self
  rescue StandardError => e
    error_report("crawl error", e)
    # エラーログをメールで送信
    send_error

    @log.error("error exit")
    false
  end

  #
  # エラーをログに出力、メールで送信用に格納
  # Param:: String label エラーの見出し
  # Param:: ext エラー
  # Return:: self
  #
  def error_report(label, exc)
    e = "#{label} #{Time.now.strftime('%Y/%m/%d %H:%M:%S')}\n\n#{exc}\n".toutf8 + $@.join("\n")
    @log.error(e)
    @error << e
  end

  #
  # エラーをログをメールで転送
  # Return:: self
  #
  def send_error
    return false if @error.length.zero?

    # # メールサーバ設定
    # Mail.defaults do
    #   delivery_method :smtp, {
    #     :address => "smtp.gmail.com", # smtpサーバのアドレス
    #     :port => 587,
    #     :user_name => "bata44883", # smtpサーバに対するユーザ名
    #     :password => "bata4488333", # smtpサーバに対するパスワード
    #     :authentication => :plain
    #   }
    # end
    #
    # # メール送信
    # nowtime = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    # mail = Mail.new do
    #   to   'bata44883@gmail.com'
    #   from 'bata44883@gmail.com'
    # end
    #
    # mail.charset = 'utf-8'
    # mail.subject = "同期エラー(#{nowtime}) - #{@company}"
    # mail.body = "#{@company}の同期クローラで#{@error.length}件のエラーが発生しました。 #{nowtime}\n\n\n" + @error.join("\n\n==============================\n\n")
    # mail.deliver!

    true
  end

  #
  # クロールキューにURLを追加
  # Param:: Int depth クロール深度
  # Return:: self
  #
  def append_quere(de)
    # クロールキューにURIを追加
    uri = @a.page.uri
    (@a.page / "a").each do |a|
      href = join_uri(uri, a[:href])
      if check_uri(href)
        @q << [href, de]
        @v << href
      end
    end

    self
  end

  #
  # UIDの重複チェック
  # Param:: String uid チェックする
  # Return:: bloorean 処理をスキップする場合はfalse
  #
  def check_uid(uid)
    # UIDのない場合は除外
    return false unless uid

    # 既存情報の場合スキップ
    @rex << uid
    if @ex.include?(uid)
      @log.debug("exsist: #{uid}")
      # return false if @update == false
      return false
    end

    true
  end

  #
  # 拒否URL、許可URLのチェック
  # Param:: String uri チェックするURL文字列
  # Return:: boolean 許可されればtrue
  #
  def check_uri(uri)
    unless @crawl_allow.nil?
      return false unless @crawl_allow =~ uri
    end

    unless @crawl_deny.nil?
      return false unless @crawl_deny !~ uri
    end

    return !@v.include?(uri)
  end

  #
  # URLを絶対パスに変換、#を削除
  #
  # Param:: String base_path ベースURL文字列
  # Param:: String uri 変換する相対URL文字列
  # Return:: String 変換後のURL文字列
  #
  def join_uri(base_path, uri)
    uri.gsub!(/#.*$/, '')
    URI.join(base_path.to_s, uri.to_s).to_s
  rescue StandardError => e
    uri
  end

  #
  # Mechinizeの初期化
  #
  def mechanize_init
    @a = Mechanize.new
    @a.user_agent_alias = 'Linux Mozilla'
    @a.html_parser      = MyParser # 日本語記号対応用パーサ
    @a.read_timeout     = 180      # タイムアウト時間
    @a.max_history      = 1
    @a.verify_mode      = OpenSSL::SSL::VERIFY_NONE
    self
  end
end

#
# MechanizeのパーサNokogiriを再定義
# 記号のエンコーディングがうまくいかないので
#
class MyParser
  def self.parse(thing, url = nil,
                encoding = nil,
                options = Nokogiri::XML::ParseOptions::DEFAULT_HTML,
                &block)
    thing = NKF.nkf("-wZX--cp932", thing)
    http = Nokogiri::HTML.parse(thing, url, encoding, options, &block)
  end
end
