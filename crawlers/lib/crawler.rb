#! ruby -Ku
# クローラクラスのソースファイル
# Author::    川端洋平
# Date::      2011/05/26
# Copyright:: Copyright (c) 2011 川端洋平
require 'rubygems'
require 'mechanize'
require 'kconv'
require 'nkf'
require 'uri'
require 'logger'

require "#{File.dirname(__FILE__)}/my_string"

# クローラクラス
class Crawler
  #### インスタンス変数アクセッサ ####
  attr_reader   :d
  attr_accessor :depth, :logger

  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  def initialize(site)
    mechanize_init              # Mechinizeの初期化

    @s        = site            # サイトクロール設定
    @d        = []              # スクレイピング結果の格納

    @depth    = 99              # クロール深度デフォルト
    @retnum   = 3               # getリトライ回数
    @retsleep = 20              # getリトライ時スリープ秒
    @logger   = Logger.new($stderr) # ロガーデフォルト

    @org_crawl_allow  = ''      # 独自許可URLキーワード
    @org_crawl_deny   = ''      # 独自拒否URLキーワード

    # スクレイピング処理をメソッド化
    eval(<<-EOS
      def self.crawl_code(url)
        #{@s[:crawl_code]}
      rescue => exc
        puts exc
      end
EOS
        )

    # セーフレベル内では処理できない内容をProc化
    @load = proc { |str| @logger.info(str) }

    @nokogiri = proc{ |uri|
      # page = NKF.nkf("-wZX--cp932", open(uri).read)
      page = NKF.nkf("-wZX--cp932", URI.parse(Addressable::URI.parse(uri).normalize.to_s).read)
      Nokogiri::HTML(page, nil, 'UTF-8')
    }
  end

  # ログ:infoに書き込む（セーフレベル2内で処理）
  # Param::  String  str   ログに書き込む内容
  def info(str)
    @load.call(str)
  end

  # 2次クロール（セーフレベル2内で処理）
  # Param::  String  uri  2次クロールするURI
  def nokogiri(uri)
    @nokogiri.call(uri)
  end

  # クロールメソッド
  # Param::  String  url   クロール、スクレイピングするURL
  # Param::  Integer depth 現在のクロール深度
  def crawl(url, depth = 1)
    #### クロールキューの初期化 ####
    url_queue = [ [url, depth] ]

    #### クロールループ ####
    loop do
      break if url_queue.length < 1
      url, depth = url_queue.shift

      #### 既にクロール済みのページかどうか ####
      next if @a.visited?(url)

      #### ページの取得 ####
      @logger.info("#{depth} -> #{url}")

      #### ローカル変数 ####
      count = 0

      #### Nokogiri ####
      begin
        page = @a.get(url)
      rescue => exc
        count += 1
        if count <= @retnum
          sleep @retsleep
          @logger.warn("retry #{count} : #{url}")
          mechanize_init
          retry
        else
          @logger.error("#{exc} : #{url}\n".toutf8 + $@)
          return
        end
      end

      #### ページ情報のスクレイピング ####
      Thread.new do
        $SAFE = 2
        crawl_code(url)
      end.join

      #### 子要素へのクロール ####
      page.links.each do |a|
        begin
          href = join_uri(url, a.href)

          if depth + 1 < @depth && check_uri(href) && !@a.visited?(href)
            url_queue << [href, depth + 1]
          end
        rescue => exc
          @logger.error("#{exc}\n".toutf8 + $@)
        end
      end
    end
  end

  # 拒否URL、許可URLのチェック
  # Param:: String uri チェックするURL文字列
  # Return:: boolean 許可されればtrue
  def check_uri(uri)
    unless @s[:crawl_allow].nil? || @s[:crawl_allow].empty?
      return false  unless /#{@s[:crawl_allow]}/ =~ uri
    end

    unless @s[:crawl_deny].nil? || @s[:crawl_deny].empty?
      return false unless /#{@s[:crawl_deny]}/ !~ uri
    end

    #     unless @s[:base_url].nil? ||  @s[:base_url].empty?
    #       return false  unless /^#{@s[:base_url]}/  =~ uri
    #     end

    unless @org_crawl_allow.nil? || @org_crawl_allow.empty?
      return false unless /#{@org_crawl_allow}/ =~ uri
    end

    unless @org_crawl_deny.nil? || @org_crawl_deny.empty?
      return false  unless /#{@org_crawl_deny}/ !~ uri
    end

    return true
  end

  # URLを絶対パスに変換、#を削除
  # Param::   String base_path ベースURL文字列
  # Param::   String uri       変換する相対URL文字列
  # Return::  String           変換後のURL文字列
  def join_uri(base_path, uri)
    uri.gsub!(/#.*$/, '')
    URI.join(base_path.to_s, uri.to_s).to_s
  rescue
    uri
  end

  # Mechinizeの初期化
  def mechanize_init
    @a                  = Mechanize.new   # クローラ
    @a.user_agent_alias = 'Linux Mozilla' # エージェント（alias）
    @a.html_parser      = MyParser        # 日本語記号対応用パーサ
    @a.read_timeout     = 180             # タイムアウト時間
  end
end

# MechanizeのパーサNokogiriを再定義
# 記号のエンコーディングがうまくいかないので
class MyParser
  # パーサの再定義
  def self.parse(thing, url = nil, encoding = nil,
                 options = Nokogiri::XML::ParseOptions::DEFAULT_HTML, &block)
    thing = NKF.nkf("-wZX--cp932", thing)
    Nokogiri::HTML.parse(thing, url, encoding, options, &block)
  end
end
