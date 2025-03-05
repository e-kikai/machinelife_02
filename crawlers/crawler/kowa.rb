#! ruby -Ku
#
# クローラクラス(for 興和機械)のソースファイル
# Author::    川端洋平
# Date::      2013/02/07
# Copyright:: Copyright (c) 2014 川端洋平
#
require "#{File.dirname(__FILE__)}/base"

# クローラクラス
class Kowa < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize
    # 親クラスのコンストラクタ
    super()

    @company    = '興和機械株式会社'
    @company_id = 189
    # @start_uri  = 'https://www.kowakikai.jp/products/'
    @start_uri  = 'https://www.kowakikai.jp/list/?search=&id=1'

    # @crawl_allow = %r{products/category}
    @crawl_allow = %r{search=}

    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p / 'ul.l-card a').each do |m|
      # @log.debug((m % '.l-card-title').text.f)
      detail_uri  = m[:href].f
      uid = (m % '.l-card-title').text.f.match(/在庫No:([0-9A-Za-z-]+)/)[1]

      # @log.debug(uid)
      # @log.debug(detail_uri)

      next unless check_uid(uid)

      #### ディープクロール ####
      detail_uri = join_uri(@p.uri, detail_uri)
      p2 = nokogiri(detail_uri)

      temp = {
        uid:,
        no: uid,
        name: (p2 % '.itemDetail-table tr:nth(2) td').text.f,
        hint: (p2 % '.itemDetail-table tr:nth(2) td').text.f,
        maker: (p2 % '.itemDetail-table tr:nth(3) td').text.f,
        model: (p2 % '.itemDetail-table tr:nth(4) td').text.f,
        year: (p2 % '.itemDetail-table tr:nth(5) td').text.f.gsub(/[^0-9]/, ''),
        spec: (p2 % '.itemDetail-table tr:nth(6) td').text.f,
        location: (p2 % '.itemDetail-table tr:nth(8) td').text.f,
        used_pdfs: {},
        used_imgs: []
      }

      case temp[:location]
      when /木曽岬/
        temp[:addr1] = "三重県"
        temp[:addr2] = "桑名郡木曽岬町"
        temp[:addr3] = "源緑輪中115番地1"
      when /加賀/
        temp[:addr1] = "石川県"
        temp[:addr2] = "加賀市"
        temp[:addr3] = "宇谷町ヤ1番地29 宇谷野工場団地内"
      when /愛西/
        temp[:addr1] = "愛知県"
        temp[:addr2] = "愛西市"
        temp[:addr3] = "西保町南川原76-1"
      end

      if /^([0-9]+)(万円)$/ =~ (p2 % '.itemDetail-table tr:nth(9) td').text.f
        temp[:price] = Regexp.last_match(1).to_i * 10_000
      end

      # 主能力
      if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
        temp[:capacity] = Regexp.last_match(2).gsub(/[^0-9.]/, '').to_f if /(芯間:|\*)([0-9\,.]+)/ =~ temp[:spec]
      elsif temp[:name].match?(/プレス/)
        if /([0-9\,.]+)T(.*)$/i =~ temp[:name]
          temp[:hint] = Regexp.last_match(2).f
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
        elsif /([0-9\,.]+)T/i =~ temp[:model] || /([0-9\,.]+)T/i =~ temp[:spec]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
        end
      elsif /ベンダー|ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
        temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
      elsif temp[:name].match?(/(シャーリング|ベンディングロール)/)
        if /\*([0-9\,.]+)/i =~ temp[:spec]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
        elsif /([0-9\,.]+)mm/i =~ temp[:spec]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
        elsif /([0-9\,.]+)m×/i =~ temp[:spec]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f * 1000
        end
      elsif temp[:name].match?(/(コンプレッサ|コンプッレサ)/)
        if /([0-9\,.]+)KW(.*)$/i =~ temp[:name]
          temp[:hint] = Regexp.last_match(2).f
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
        elsif /([0-9\,.]+)KW/i =~ temp[:spec]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
        end
      elsif /スポット溶接/ =~ temp[:name]
        temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KVA/i =~ temp[:spec]
      elsif /溶接/ =~ temp[:name]
        temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
      elsif temp[:name].match?(/フォークリフト|ローリフト|チェーンブロック|ホイスト|クレーン|リフタ/)
        if /([0-9\,.]+)t/i =~ temp[:model]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
        elsif /([0-9\,.]+)kg/i =~ temp[:spec]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f / 1000
        end
      elsif temp[:name].match?(/定盤/)
        if /([0-9\,.]+)(×|\*)([0-9\,.]+)(×|\*)?/i =~ "#{temp[:model]} #{temp[:spec]}"
          le1 = Regexp.last_match(1).to_s.gsub(/[^0-9.]/, '').to_f
          le2 = Regexp.last_match(3).to_s.gsub(/[^0-9.]/, '').to_f

          temp[:capacity] = [le1, le2].max
        end
      end

      # 画像
      (p2 / '.thumbItem img').each do |i|
        temp[:used_imgs] << i[:src]
      end

      # PDF
      (p2 / 'a.itemDetail-guide-btn').each do |i|
        temp[:used_pdfs]['仕様書'] = i[:href]
      end

      # youtube
      temp[:youtube] = nil
      (p2 / 'iframe').each do |i|
        temp[:youtube] = "http://youtu.be/#{i[:src].gsub(%r{^(.*/)}, '')}"
      end

      @d << temp
      @log.debug(temp)
    rescue StandardError
      error_report("scrape error (#{temp[:uid]})", exc)
    end

    # exit

  #   (@p / '.top-item-list .one-fix').each do |m|
  #     #### 既存情報の場合スキップ ####
  #     detail_link = m % '.img a'
  #     detail_uri  = detail_link[:href].f
  #     uid         = (m % '.no-base p').text.f
  #     next unless check_uid(uid)

  #     #### ディープクロール ####
  #     detail_uri = join_uri(@p.uri, detail_uri)
  #     p2 = nokogiri(detail_uri)

  #     temp = {
  #       uid:,
  #       no: uid,
  #       name: (p2 % '.deta-table tr:nth(2) td').text.f,
  #       hint: (p2 % '.deta-table tr:nth(2) td').text.f,
  #       maker: (p2 % '.deta-table tr:nth(3) td').text.f,
  #       model: (p2 % '.deta-table tr:nth(4) td').text.f,
  #       year: (p2 % '.deta-table tr:nth(5) td').text.f.gsub(/[^0-9]/, ''),
  #       spec: (p2 % '.deta-table-02 tr:nth(1) td').text.f,
  #       location: (p2 % '.deta-table-02 tr:nth(3) td').text.f,
  #       used_pdfs: {},
  #       used_imgs: []
  #     }

  #     if /^([0-9]+)(万円)$/ =~ (p2 % '.deta-table-02 tr:nth(2) td').text.f
  #       temp[:price] = Regexp.last_match(1).to_i * 10_000
  #     end

  #     # 主能力
  #     if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
  #       temp[:capacity] = Regexp.last_match(2).gsub(/[^0-9.]/, '').to_f if /(芯間:|\*)([0-9\,.]+)/ =~ temp[:spec]
  #     elsif temp[:name].match?(/プレス/)
  #       if /([0-9\,.]+)T(.*)$/i =~ temp[:name]
  #         temp[:hint] = Regexp.last_match(2).f
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
  #       elsif /([0-9\,.]+)T/i =~ temp[:model] || /([0-9\,.]+)T/i =~ temp[:spec]
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
  #       end
  #     elsif /ベンダー|ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
  #       temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
  #     elsif temp[:name].match?(/(シャーリング|ベンディングロール)/)
  #       if /\*([0-9\,.]+)/i =~ temp[:spec]
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
  #       elsif /([0-9\,.]+)mm/i =~ temp[:spec]
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
  #       elsif /([0-9\,.]+)m×/i =~ temp[:spec]
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f * 1000
  #       end
  #     elsif temp[:name].match?(/(コンプレッサ|コンプッレサ)/)
  #       if /([0-9\,.]+)KW(.*)$/i =~ temp[:name]
  #         temp[:hint] = Regexp.last_match(2).f
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
  #       elsif /([0-9\,.]+)KW/i =~ temp[:spec]
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
  #       end
  #     elsif /スポット溶接/ =~ temp[:name]
  #       temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KVA/i =~ temp[:spec]
  #     elsif /溶接/ =~ temp[:name]
  #       temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
  #     elsif temp[:name].match?(/フォークリフト|ローリフト|チェーンブロック|ホイスト|クレーン|リフタ/)
  #       if /([0-9\,.]+)t/i =~ temp[:model]
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
  #       elsif /([0-9\,.]+)kg/i =~ temp[:spec]
  #         temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f / 1000
  #       end
  #     elsif temp[:name].match?(/定盤/)
  #       if /([0-9\,.]+)(×|\*)([0-9\,.]+)(×|\*)?/i =~ "#{temp[:model]} #{temp[:spec]}"
  #         le1 = Regexp.last_match(1).to_s.gsub(/[^0-9.]/, '').to_f
  #         le2 = Regexp.last_match(3).to_s.gsub(/[^0-9.]/, '').to_f

  #         temp[:capacity] = [le1, le2].max
  #       end
  #     end

  #     # 画像
  #     (p2 / '#imageList img').each do |i|
  #       temp[:used_imgs] << "http://www.kowakikai.jp#{i[:src]}"
  #     end

  #     # PDF
  #     (p2 / '.deta-table-02 tr:nth(4) td a').each do |i|
  #       temp[:used_pdfs]['仕様書'] = "http://www.kowakikai.jp#{i[:href]}"
  #     end

  #     # youtube
  #     temp[:youtube] = nil
  #     (p2 / 'iframe').each do |i|
  #       temp[:youtube] = "http://youtu.be/#{i[:src].gsub(%r{^(.*/)}, '')}"
  #     end

  #     @d << temp
  #     @log.debug(temp)
  #   rescue StandardError
  #     error_report("scrape error (#{temp[:uid]})", exc)
  #   end

    self
  end
end
