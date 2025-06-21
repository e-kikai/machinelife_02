#! ruby -Ku
#
# クローラクラス(for 丸善機械)のソースファイル
# Author::    川端洋平
# Date::      2025/04/09
# Copyright:: Copyright (c) 2025 川端洋平
#
require File.dirname(__FILE__) + '/base'

# クローラクラス
class Maruzen < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    # @company    = '丸善機械株式会社'
    # @company_id = 92
    # @start_uri  = 'https://maruzen-m.co.jp/itemall/'

    # ダミーデータ
    @company    = 'xxx'
    @company_id = 92999
    @start_uri  = 'dd'

    @crawl_allow = %r{/itemall/page/[0-9]+/}
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p / '.infoListBox').each do |m|
      #### 売約済みをスキップ ####
      next if (m % '.listthumbImage noscript img')['src'].match?("sold.jpg")

      #### 既存情報の場合スキップ ####
      detail_uri = (m % '.entryTitle a')[:href]
      uid        = detail_uri.scan(/[0-9]{2,}/).flatten.first
      next unless check_uid(uid)

      #### ディープクロール ####
      detail_uri = join_uri(@p.uri, detail_uri)
      p2 = nokogiri(detail_uri)

      temp = {
        uid:,
        name: (p2 % 'tr:nth(1) .table_td').text.f.strip,
        no: (p2 % 'tr:nth(2) .table_td').text.f.strip,
        maker: (p2 % 'tr:nth(3) .table_td').text.f.strip,
        model: (p2 % 'tr:nth(4) .table_td').text.f.strip,
        year: (p2 % 'tr:nth(5) .table_td').text.f.strip,
        location: "本社",
        spec: (p2 % 'tr:nth(6) .table_td').text.f.strip,
      }

      temp[:youtube] = p2.at('.youtubethumb a')[:href].scan(%r{v=([a-zA-Z0-9_-]+)}).flatten.first if p2.at('.youtubethumb a')
      temp[:hint]    = temp[:name].gsub('CNC', 'NC')

      temp = temp.transform_values do |v|
        v.is_a?(String) && v.strip == "-" ? "" : v
      end

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
      temp[:used_imgs] = (p2 / '.itemimglist img').filter_map do |i|
        join_uri(detail_uri, i["data-src"])
      end

      @d << temp
      @log.debug(temp)
    rescue StandardError => e
      error_report("scrape error (#{temp[:uid]})", e)
    end

    self
  end
end
