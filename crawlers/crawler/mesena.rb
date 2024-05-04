#! ruby -Ku
#
# クローラクラス(for メセナ)のソースファイル
# Author::    川端洋平
# Date::      2013/02/07
# Copyright:: Copyright (c) 2014 川端洋平
#
require File.dirname(__FILE__) + '/base'

# クローラクラス
class Mesena < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company    = '株式会社メセナ'
    # @company_id = 375 # test
    @company_id = 388
    @start_uri  = 'https://www.mesena-m.com/category/used-machines/'

    @crawl_allow = /\/category\/used\-machines\/page\/[0-9]+$/
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'article').each do |m|
      begin
        #### 売約済みをスキップ ####
        next if m%'.sold-out'

        #### 既存情報の場合スキップ ####
        detail_uri = (m%'h1.loop-title a:nth(1)')[:href]
        uid        = detail_uri.gsub(/[^0-9]/, '')
        next if uid == "1916"
        next unless check_uid(uid)

        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, detail_uri)
        p2 = nokogiri(detail_uri)

        temp = {
          :uid   => uid,
          :no    => (p2%'.single-list li:nth(1)').text.f.gsub(/^(.*\:)/, ''),
          :name  => (p2%'.single-list li:nth(2)').text.f.gsub(/^(.*\:)/, ''),
          :maker => (p2%'.single-list li:nth(3)').text.f.gsub(/^(.*\:)/, ''),
          :model => (p2%'.single-list li:nth(4)').text.f.gsub(/^(.*\:)/, ''),
          :year  => (p2%'.single-list li:nth(6)').text.f.gsub(/^(.*\:)/, '').gsub(/[^0-9]/, ''),
          :location => "本社",

          :used_imgs => [],
        }

        temp[:spec] = (p2%'div.single-content').text.f if p2%'div.single-content'
        temp[:hint] = temp[:name]

        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $2.gsub(/[^0-9.]/, '').to_f if /(心間|芯間)([0-9\,.]+)/ =~ temp[:spec]
        elsif /プレス/ =~ temp[:name] && /NC|ブレーキ/ !~ temp[:name]
          if /([0-9\,.]+)TON(.*)$/i =~ temp[:name]
            temp[:hint] = $2.f
            temp[:capacity] = $1.gsub(/[^0-9.]t/, '').to_f
          elsif /([0-9\,.]+)ton/i =~ temp[:model] || /([0-9\,.]+)t/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /万能.*ベンダ/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)t/i =~ temp[:spec]
        elsif /ベンダー|ブレーキ/ =~ temp[:name] && /NC|万能/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /\*([0-9\,.]+)/i =~ temp[:spec]
        elsif /ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /φ([0-9\,.]+)/i =~ temp[:spec]
        elsif /(シャーリング|ベンディングロール)/ =~ temp[:name]
          if /^([0-9\,.]+)/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /溶接/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
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
        (p2/'.single-content img').each do |i|
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
