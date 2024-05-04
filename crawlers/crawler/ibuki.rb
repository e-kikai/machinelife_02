#! ruby -Ku
#
# クローラクラス(for 伊吹産業)のソースファイル
# Author::    川端洋平
# Date::      2013/02/07
# Copyright:: Copyright (c) 2014 川端洋平
#
require File.dirname(__FILE__) + '/base'

# クローラクラス
class Ibuki < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company    = '伊吹産業株式会社'
    @company_id = 301
    @start_uri  = 'http://www.ibuki-in.co.jp/product/data.php?c=search-list&page=1'

    @crawl_allow = /c=search-list&page=[0-9]+$/
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'a.btnDtl[href*="detail"]').each do |m|
      begin
        #### 既存情報の場合スキップ ####
        detail_link = m
        detail_uri  = detail_link[:href].f

        next unless /item=([A-Za-z0-9]+)$/ =~ detail_uri
        uid         = $1

        next unless check_uid(uid)

        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, detail_uri)
        p2 = nokogiri(detail_uri)

        (p2%'.pType').remove if p2%'.pType'

        temp = {
          :uid   => uid,
          :no    => uid,
          :name  => (p2%'h3.blBox').text.f,
          :hint  => (p2%'h3.blBox').text.f,
          :maker => (p2%'table.bgBlue tr:nth(1) td').text.f,
          :model => (p2%'table.bgBlue tr:nth(2) td').text.f,
          :year  => (p2%'table.bgBlue tr:nth(3) td').text.f.gsub(/[^0-9]/, ''),
          :spec  => (p2%'table.bgBlue tr:nth(4) td').text.f,
          :location => (p2%'table.bgBlue tr:nth(5) td').text.f,
          :comment => (p2%'table.bgBlue tr:nth(6) td').text.f + " " + (p2%'#machineState p').text.f,
          addr1:    "大阪府",
          addr2:    "東大阪市",
        }

        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $2.gsub(/[^0-9.]/, '').to_f if /(心間|芯間)([0-9\,.]+)/ =~ temp[:spec]
        elsif /プレス/ =~ temp[:name]
          if /([0-9\,.]+)TON(.*)$/i =~ temp[:name]
            temp[:hint] = $2.f
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)ton/i =~ temp[:model] || /([0-9\,.]+)ton/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /φ([0-9\,.]+)/i =~ temp[:spec]
        elsif /(シャーリング|ベンディングロール)/ =~ temp[:name]
          if /切断能力([0-9\,.]+)/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /(コンプレッサ|コンプッレサ)/ =~ temp[:name]
          if /([0-9\,.]+)kw/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /フォークリフト|ローリフト|チェーンブロック|ホイスト|クレーン|リフタ/ =~ temp[:name]
          if /([0-9\,.]+)t/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)トン/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)kg/i =~ temp[:spec]
            temp[:capacity] = ($1.gsub(/[^0-9.]/, '').to_f) / 1000
          end
        elsif /定盤/ =~ temp[:name]
          if /([0-9\,.]+)(×|\*)([0-9\,.]+)(×|\*)?/i =~ temp[:model] + ' ' +  temp[:spec]
            le1 = $1
            le2 = $3

            le1 = le1.gsub(/[^0-9.]/, '').to_f
            le2 = le2.gsub(/[^0-9.]/, '').to_f

            temp[:capacity] = le1 > le2 ? le1 : le2
          end
        end

        # 画像
        temp[:used_imgs] = []
        (p2/'img#staffMainL').each do |i|
          next if /noimage/ =~ i[:src]
          temp[:used_imgs] << join_uri(detail_uri, i[:src])
        end

        (p2/'#machineStatePhoto img').each do |i|
          next if /noimage/ =~ i[:src]
          temp[:used_imgs] << join_uri(detail_uri, i[:src])
        end

        @d << temp
        @log.debug(temp)
      rescue => exc
        error_report("scrape error (#{temp[:uid]})", exc)
      end
    end

    return self
  end
end
