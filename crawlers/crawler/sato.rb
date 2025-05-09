#! ruby -Ku
#
# クローラクラス(for 佐藤機械)のソースファイル
# Author::    川端洋平
# Date::      2012/5/17
# Copyright:: Copyright (c) 2012 川端洋平
#
require  File.dirname(__FILE__) + '/base'

# クローラクラス
class Sato < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company    = '有限会社佐藤機械'
    @company_id = 20
    # @start_uri  = 'http://www.ric.hi-ho.ne.jp/sato-kikai/list/all-list.html'
    @start_uri  = 'http://www.satokikai.net/list/all-list.php'
    # @start_uri  = 'http://www.satokikai.net/'

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
    (@p/'table.table_03 tr.tr1, table.table_03 tr.tr2').each do |m|
      begin
        #### 既存情報の場合スキップ ####
        next unless m%'td:nth(3) a'
        uid = (m%'td:nth(3) a')[:href].f
        next unless check_uid(uid)

        #### 売約済みをスキップ ####
        next if (m%'td:nth(7)').text.f == '売約済'

        temp = {
          :uid   => uid,
          :no    => (m%'td:nth(1)').text.f,
          :maker => (m%'td:nth(4)').text.f,
          :year  => (m%'td:nth(5)').text.f,
          :spec  => (m%'td:nth(6)').text.f,
          :location => '本社'
        }

        # 機械名(ヒント)
        if (m%'td:nth(2)').text.f == '' || (m%'td:nth(2)').text.f == '-'
          temp[:name]  = (m % 'td:nth(3)').text.f
        else
          temp[:name]  = (m % 'td:nth(2)').text.f
          temp[:model] = (m % 'td:nth(3)').text.f
        end
        temp[:hint] = temp[:name]

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
        elsif /定盤/ =~ temp[:name]
          if /([0-9\,.]+)\*([0-9\,.]+)/i =~ temp[:spec]
            le1 = $1
            le2 = $2

            le1 = le1.gsub(/[^0-9.]/, '').to_f
            le2 = le2.gsub(/[^0-9.]/, '').to_f

            temp[:capacity] = le1 > le2 ? le1 : le2
          end
        end

        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, uid)
        p2 = nokogiri(detail_uri)

        # 画像
        temp[:used_imgs] = []
        (p2/'#thumbnail a').each do |i|
          temp[:used_imgs] << join_uri(detail_uri, i[:href])
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
