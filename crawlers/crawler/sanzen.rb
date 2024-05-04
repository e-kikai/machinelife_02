#! ruby -Ku
#
# クローラクラス(for 三善機械)のソースファイル
# Author::    川端洋平
# Date::      2013/01/20
# Copyright:: Copyright (c) 2013 川端洋平
#
require File.dirname(__FILE__) + '/base'
require 'csv'

# クローラクラス
class Sanzen < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company    = '有限会社三善機械'
    @company_id = 23
    @start_uri  = 'https://www.sanzenkikai.co.jp/machine/'

    @crawl_allow = /(工作機械|machiningcenter|millingmachine|鍛圧|その他|周辺工具|ツーリング|切削工具|測定工具)/
    @crawl_deny  = /(page|activity)/
  end

  #
  # スクレイピング処理
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    trs = {
      # "カテゴリー:" => :hint,
      "メーカー名:" => :maker,
      "管理番号:" => :no,
      "機械名:" => :name,
      "型式:" => :model,
      "年式:" => :year,
      "仕様:" => :spec,
      "本体価格:" => :ekikai_price
    }

    temp = { location: "本社" }
    @p.search('table.mceEditable tr').each do |tr|
      th = tr.search('th').text.f
      td = tr.search('td').text.f

      temp[trs[th]] = td if trs.include? th

      temp[:ekikai_price] = temp[:ekikai_price].to_s.gsub(/\D/, '').to_i
      temp[:ekikai_price] = nil if temp[:ekikai_price] < 1
    end

    temp[:hint] = temp[:name]
    temp[:uid]  = temp[:no]
    return unless check_uid(temp[:uid])

    return unless temp[:name]

    # 主能力
    if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
      temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /心間([0-9]+)/ =~ temp[:spec]
    elsif /プレス/ =~ temp[:name]
      temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)t/i =~ temp[:spec]
    elsif /(コンプレッサ|モーター)/ =~ temp[:name]
      temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)kw/i =~ temp[:spec]
    elsif /溶接/ =~ temp[:name]
      temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
    end

    # 画像
    temp[:used_imgs] = []
    (@p/'.cc-m-gallery-cool-item a').each_with_index do |img, i|
      # @log.debug(URI.escape(join_uri(detail_uri, i[:href])))
      # temp[:used_imgs] << "#{URI.encode_www_form_component(img['data-href'])}##{i}"
      temp[:used_imgs] << img['data-href']
    end

    @d << temp if temp[:name]
    @log.debug(temp)

    self
  end

  #
  # 2次クロール（セーフレベル2内で処理）
  # Param:: String uri 2次クロールするURI
  #
  def nokogiri(uri)
    page = NKF.nkf("-wX--cp932", open(uri).read)
    Nokogiri::HTML(page, nil, 'UTF-8')
  end

  def append_quere(de)
    # クロールキューにURIを追加
    uri = @a.page.uri
    (@a.page/"a").each do |a|
      # href = join_uri(uri, a[:href])
      href = "https://www.sanzenkikai.co.jp/" + a[:href].to_s
      # @log.debug href

      if check_uri(href)
        @q << [href, de]
        @v << href
      end
    end

    self
  end
end

class MyParser
  def self.parse(thing, url = nil,
                 encoding = nil,
                 options = Nokogiri::XML::ParseOptions::DEFAULT_HTML,
                 &block)
    thing = NKF.nkf("-wX--cp932", thing)
    Nokogiri::HTML.parse(thing, url, encoding, options, &block)
  end
end
