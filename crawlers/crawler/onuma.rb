#! ruby -Ku
#
# クローラクラス(for 大沼機工)のソースファイル
# Author::    川端洋平
# Date::      2012/5/17
# Copyright:: Copyright (c) 2012 川端洋平
#
require File.dirname(__FILE__) + '/base'
require 'csv'

# クローラクラス
class Onuma < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize
    # 親クラスのコンストラクタ
    super()

    @company    = '大沼機工株式会社'
    @company_id = 42
    @start_uri  = 'http://www.onuma-mc.co.jp/stock.php?maxRowID=5'

    @crawl_allow = /stock\.php\?maxRowID=5&pageNum=[0-9]+$/
    @crawl_deny  = nil

    # ジャンルCSVの取得
    # @genre_list = {}
    # csv_uri = 'http://www.zenkiren.net/system/csv/onuma_genres.csv'
    # genre_csv = NKF.nkf("-wZX--cp932", open(csv_uri).read)
    # CSV.parse(genre_csv) do |rows|
    #   @genre_list[rows[5]] = rows[6]
    # end

    @genre_list = CSV.open("#{File.dirname(__FILE__)}/../csv/onuma_genres.csv", headers: true, encoding: 'sjis').to_h { |row| [row[5], row[6]] }
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'#TableList tbody tr').each do |m|
      begin
        next if m%'th'

        #### 既存情報の場合スキップ ####
        uid = (m%'td:nth(3)').text.f
        next unless check_uid(uid)

        temp = {
          :uid   => uid,
          :no    => (m%'td:nth(4)').text.f,
          :name  => (m%'td:nth(5)').text.f,
          :maker => (m%'td:nth(6)').text.f,
          :model => (m%'td:nth(8)').text.f,
          :year  => (m%'td:nth(7)').text.f,
          :spec  => '',
          :location => '本社',
        }
        temp[:hint] = temp[:name].gsub(/\((.*?)\)$/, '').strip

        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, m.%('td:nth(3) a')[:href])
        p2 = nokogiri(detail_uri)

        #### 仕様 ####
        spec_temp = []
        (p2/'table.spec th').each do |n|
          nlabel = n.text.f
          ndata  = n.next_element.text.f

          next if ndata == ''

          if nlabel == '保管'
            temp[:location] = ndata
          elsif nlabel == '管理状況'
            temp[:comment] = ndata
          elsif /^(在庫No|問合せ)$/ !~ nlabel
            if ndata != '' && ndata != nil
              ndata.gsub!(')', ':') if /\(.*\)/ !~ ndata
              if /^[\-\?]?$/ =~ nlabel
                spec_temp << ndata
              else
                spec_temp << "#{nlabel}:#{ndata}"
              end
            end
          end
        end
        temp[:spec] = spec_temp.join(' | ')

        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /B\)[0-9]+×([0-9]+)/ =~ temp[:spec]
        elsif /プレス/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)t/i =~ temp[:spec]
        elsif /ラジアル/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /振り([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm×[0-9\,.]+t/i =~ temp[:spec]
        elsif /(コンプレッサ|モーター)/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)kw/i =~ temp[:spec]
        elsif /(ホイスト|チェンブロック|クレーン)/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)t/i =~ temp[:spec]
        elsif /(シャーリング|ベンディングロール)/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm×/i =~ temp[:spec]
        elsif /スポット溶接/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KVA/i =~ temp[:spec]
        elsif /溶接/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
        elsif /スロッタ/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /S\)([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /エアータンク/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)リットル/i =~ temp[:spec]
        elsif /バンドソー/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /φ([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /フォークリフト|ローリフト/ =~ temp[:name]
          if /([0-9\,.]+)t/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)kg/i =~ temp[:spec]
            temp[:capacity] = ($1.gsub(/[^0-9.]/, '').to_f) / 1000
          end
        elsif /定.?盤/ =~ temp[:name]
          if /([0-9\,.]+)×([0-9\,.]+)/i =~ temp[:spec]
            le1 = $1
            le2 = $2

            le1 = le1.gsub(/[^0-9.]/, '').to_f
            le2 = le2.gsub(/[^0-9.]/, '').to_f

            temp[:capacity] = le1 > le2 ? le1 : le2
          end
        end

        # ジャンル
        (p2/'table.detailTable > tbody > tr > td').each do |i|
          if /コード.([0-9-]+)/ =~ i.text.f
            if @genre_list[$1]
              temp[:genre_id] = @genre_list[$1]
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
      rescue => exc
        error_report("scrape error (#{temp[:uid]})", exc)
      end
    end

    return self
  end
end
