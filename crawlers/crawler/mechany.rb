#! ruby -Ku
#
# クローラクラス(for メカニー)のソースファイル
# Author::    川端洋平
# Date::      2012/5/17
# Copyright:: Copyright (c) 2012 川端洋平
#
require File.dirname(__FILE__) + '/base'

# クローラクラス
class Mechany < Base

  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize
    # 親クラスのコンストラクタ
    super()

    @company    = '株式会社メカニー'
    @company_id = 232
    @start_uri  = 'https://www.mechany.com/?s=&post_type=products&search_type=free'
    @q << ["https://www.mechany.com/new-machine/products", 2]

    @crawl_allow = %r{/new-machine/products/[^/]*$}
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    # (@p/'a.com-panel-01').each do |m|
    (@p/'.com-panel-01').each do |m|
      begin
        uid = (m % "dl.info-dl-01 dd:first").text.f
        next unless check_uid(uid)

        #### ディープクロール ####
        # detail_uri = m[:href]
        detail_uri = (m % "a")[:href]
        p2 = nokogiri(detail_uri)

        next if (p2%'.info-dl-02').text.f =~ /現状渡し機械/

        temp = {
          uid: uid,
          no: uid,
          location: '滋賀マシンセンター',
          used_imgs: [],
          used_pdfs: {}
        }

        (p2/'dt').each do |dt|
          next unless (dt%'+ dd')

          dd_text = (dt%'+ dd').text.f

          case dt.text.f
          # when /在庫番号/; temp[:no]      = dd_text
          when /機械名/;   temp[:name]    = dd_text
          # when /カテゴリ/; temp[:hint]    = dd_text
          when /メーカー/; temp[:maker]   = dd_text
          when /型番/;     temp[:model]   = dd_text
          when /年式/;     temp[:year]    = dd_text
          when /仕様/;     temp[:spec]    = dd_text
          when /コメント/; temp[:comment] = dd_text
          end
        end

        temp[:hint] = temp[:name].gsub(/\(新品\)|/, '')

        # next unless check_uid(temp[:uid])

        # # 主能力
        # if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /芯間\:([0-9\,.]+)/ =~ temp[:spec]
        # elsif /万能.*プレスブレーキ/ =~ temp[:name] && /NC/ !~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ton/i =~ temp[:spec]
        # elsif /プレスブレーキ/ =~ temp[:name]
        #   temp[:capacity] = $3.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)(ton|T)\*([0-9\,.]+)/i =~ temp[:spec]
        # elsif /(プレス|ハンマーパンチ)/ =~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ton/i =~ temp[:spec]
        # elsif /ラジアル/ =~ temp[:name] && /NC/ !~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /振り\:([0-9\,.]+)/i =~ temp[:spec]
        # elsif /万能.*ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ton/i =~ temp[:spec]
        # elsif /本ロール/ =~ temp[:name] && /NC/ !~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /L\:([0-9\,.]+)/i =~ temp[:spec]
        # elsif /ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
        #   temp[:capacity] = $2.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ton\*([0-9\,.]+)/i =~ temp[:spec]
        # elsif /(コンプレッサ|モーター)/ =~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)kw/i =~ temp[:spec]
        # elsif /シャーリング/ =~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /\*([0-9\,.]+)/i =~ temp[:spec]
        # elsif /スポット溶接/ =~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KVA/i =~ temp[:spec]
        # elsif /溶接/ =~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
        # elsif /エアータンク/ =~ temp[:name]
        #   temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)リットル/i =~ temp[:spec]
        # elsif /フォーク|ローリフト|ホイスト|クレーン|チェーンブロック/ =~ temp[:name]
        #   if /([0-9\,.]+)(ton|トン)/i =~ temp[:spec]
        #     temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
        #   elsif /([0-9\,.]+)kg/i =~ temp[:spec]
        #     temp[:capacity] = ($1.gsub(/[^0-9.]/, '').to_f) / 1000
        #   end
        # elsif /放電加工/ =~ temp[:name]
        #   temp[:genre_id] = 220
        # elsif /定.?盤/ =~ temp[:name]
        #   if /([0-9\,.]+)\*([0-9\,.]+)/i =~ temp[:spec]
        #     le1 = $1
        #     le2 = $2

        #     le1 = le1.gsub(/[^0-9.]/, '').to_f
        #     le2 = le2.gsub(/[^0-9.]/, '').to_f

        #     temp[:capacity] = le1 > le2 ? le1 : le2
        #   end
        # end

        (p2/'span.cat-ico-01.red').each do |sp|
          temp[:commission] = 1 if sp.text.f =~ /試運転/
        end

        # 動画、PDF
        (p2/'a.pdf').each do |a|
          temp[:used_pdfs]["カタログ・仕様書"] = join_uri(detail_uri, a[:href])
        end

        (p2/'#machine-video').each do |i|
          @log.debug i["data-video"]
          temp[:youtube] = i["data-video"]
        end

        # 画像
        (p2/'img.attachment-full').each do |i|
          temp[:used_imgs] << join_uri(detail_uri, i[:src]) unless /gif$/ =~ i[:src]
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
