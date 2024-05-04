#! ruby -Ku
#
# クローラクラス(for YMS)のソースファイル
# Author::    川端洋平
# Date::      2012/5/17
# Copyright:: Copyright (c) 2012 川端洋平
#
require  File.dirname(__FILE__) + '/base'

# クローラクラス
class Yms < Base

  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company    = '株式会社ワイ・エム・エス'
    @company_id = 22
    # @start_uri  = 'http://www.yms-net.com/list.html'
    @start_uri  = 'http://yms-net.com/list/'

    @crawl_allow = /^xxxxx$/
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'table.kikai-list tr').each do |m|
      begin
        next unless m%'td:nth(4)'

        # next if (m%'td:nth(3)').text.f =~ /売約済|在庫状況/
        next if (m%'td:nth(3)').text.f =~ /在庫状況/
        # log.debug((m%'td:nth(5)').to_s)

        #### 既存情報の場合スキップ ####
        # uid = (m%'td:nth(1)').text.f == '' ? (m%'td:nth(2)').text.f : (m%'td:nth(1)').text.f.gsub(/[^0-9a-zA-Z]/, '')
        uid = (m%'td:nth(1)').text.f
        next unless check_uid(uid)

        temp = {
          :uid   => uid,
          :no    => uid,
          :name  => (m%'td:nth(2)').text.f,
          :comment => (m%'td:nth(3)').text.f,
          :maker => (m%'td:nth(4)').text.f,
          :model => (m%'td:nth(5)').text.f,
          :spec  => (m%'td:nth(6)').text.f,
          :year  => (m%'td:nth(7)').text.f,
          # :price => (m%'td:nth(8)').text.f,
          :location => '本社',
        }

        temp[:maker] = '' if temp[:maker] == '-'
        temp[:model] = '' if temp[:model] == '-'
        temp[:hint]  = temp[:name]

        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          if /([3-9])尺/ =~ temp[:name]
            temp[:capacity] = LATER_CAP[$1.to_i]
          elsif /([0-9.]+)m/ =~ temp[:name]
            temp[:capacity] = $1.to_f * 1000
          end
        elsif /ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /プレス/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ton/i =~ temp[:spec]
        elsif /(コンプレッサ|モーター)/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KW/i =~ temp[:spec]
        elsif /スポット溶接/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KVA/i =~ temp[:spec]
        elsif /溶接/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
        elsif /チェーンブロック|ホイスト/ =~ temp[:name]
          if /([0-9\,.]+)ton/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)kg/i =~ temp[:spec]
            temp[:capacity] = ($1.gsub(/[^0-9.]/, '').to_f) / 1000
          end
        elsif /定盤/ =~ temp[:name]
          if /([0-9\,.]+)×([0-9\,.]+)/i =~ temp[:spec]
            le1 = $1
            le2 = $2

            le1 = le1.gsub(/[^0-9.]/, '').to_f
            le2 = le2.gsub(/[^0-9.]/, '').to_f

            temp[:capacity] = le1 > le2 ? le1 : le2
          end
        end

        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, (m%'td:nth(2) a')[:href])
        p2 = nokogiri(detail_uri)

        # next if NKF.nkf("-wZX--cp932", open(detail_uri).read) =~ /売約済/

        # 画像
        temp[:used_imgs] = []
        (p2/'.photos a').each do |i|
          temp[:used_imgs] << join_uri(detail_uri, i[:href])
        end

        temp[:used_pdfs] = {}
        (p2/'.items a').each do |a|
          temp[:used_pdfs]["仕様書(PDF)"] = join_uri(detail_uri, a[:href]) if a[:href] =~ /pdf$/
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
