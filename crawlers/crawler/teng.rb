#! ruby -Ku
#
# クローラクラス(for 東京エンジニアリング)のソースファイル
# Author::    川端洋平
# Date::      2013/05/12
# Copyright:: Copyright (c) 2013 川端洋平
#
require "#{File.dirname(__FILE__)}/base"
require 'csv'

# クローラクラス
class Teng < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize
    # 親クラスのコンストラクタ
    super()

    @company    = '株式会社東京エンジニアリング'
    @company_id = 76
    @start_uri  = 'http://www.t-eng.co.jp/products/used/list.cgi?c1=999&c2=999&page=1'

    @crawl_allow = /list\.cgi\?c1=999&c2=999&page=[0-9]+$/
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    locks = Queue.new
    5.times { locks.push :lock }

    @p.search('ul.usedlist li').filter_map do |m|
      ### 名前に「売約済」が入っていたらスキップ ###
      name = m.at('p:nth(3)').text.f.gsub(/NEW/i, '')
      next if name.match?(/売約|売却済|機械名/)

      ### 既存情報の場合スキップ ###
      detail_uri = join_uri(@p.uri, m.%('p:nth(3) a')[:href])
      next unless /detail.cgi\?id=([0-9]+)/ =~ detail_uri

      uid = Regexp.last_match(1)
      next unless check_uid(uid)

      Thread.new do
        lock = locks.pop

        temp = {
          uid:,
          name:,
          no: m.at('p:nth(2)').text.f,
          maker: m.at('p:nth(4)').text.f,
          model: m.at('p:nth(5)').text.f,
          year: m.at('p:nth(6)').text.f,
          location: '',
          spec: ''
        }

        temp[:hint] = temp[:name]

        # 機械名と型式が同じ場合は、型式を除去
        temp[:model] = '' if temp[:model] == temp[:name]

        ### ディープクロール ###
        p2 = nokogiri(detail_uri)

        #### 仕様 ####
        p2.search('.list_basic li span:nth(1)').each do |n|
          nlabel = n.text.f
          ndata  = n.next_element.text.f

          next if ndata == ''

          case nlabel
          when '在庫場所'
            temp[:location] =
              case ndata
              when /成田第一/; 'TEN成田第1倉庫'
              when /成田第二|第2/; 'TEN成田第2倉庫'
              when /成田第三/; 'TEN成田第3倉庫'
              when /成田第四|成田第4/; 'TEN成田第4倉庫'
              when /HUB/; 'TEN成田HUB-WORKS'
              when /山梨|鳴沢/; 'TEN山梨'
              when /熊本/; 'TEN九州'
              when /本社/; '本社'
              else ndata
              end

            if ndata.match?(/朝倉/)
              temp[:addr1] = "群馬県"
              temp[:addr2] = "伊勢崎市"
              temp[:addr3] = "田部井町3-200-1"
            elsif ndata.match?(/大阪/)
              temp[:addr1] = "大阪府"
              temp[:addr2] = "東大阪市"
              temp[:addr3] = "宝町15-10"
            end
          when '付属品'; temp[:accessory] = ndata
          when '価格(万円)'; temp[:price] = ndata
          when '現状'; temp[:spec] += " | 現状:#{ndata}"
          when '主仕様'; temp[:spec] += ndata.delete('★')
          end

          # if nlabel == '在庫場所'
          #   if /成田第一/ =~ ndata
          #     temp[:location] = 'TEN成田第1倉庫'
          #   elsif /成田第二/ =~ ndata
          #     temp[:location] = 'TEN成田第2倉庫'
          #   elsif /成田第三/ =~ ndata
          #     temp[:location] = 'TEN成田第3倉庫'
          #   elsif /HUB/ =~ ndata
          #     temp[:location] = 'TEN成田HUB-WORKS'
          #   elsif /山梨/ =~ ndata
          #     temp[:location] = 'TEN山梨'
          #   else
          #     temp[:location] = ndata
          #   end
          # elsif nlabel == '付属品'
          #   temp[:accessory] = ndata
          # elsif nlabel == '価格(万円)'
          #   temp[:price] = ndata
          # elsif nlabel == '現状'
          #   temp[:spec] += " | 現状:#{ndata}"
          # elsif nlabel == '主仕様'
          #   temp[:spec] += ndata.delete('★')
          # end
        end

        # 機械名から情報を分離
        if temp[:name].match?(/(新古品)/)
          temp[:name].gsub!('(新古品)', '')
          temp[:spec] += ' | 新古品'
        end
        if temp[:name].match?(/新品/)
          temp[:name].gsub!('新品', '')
          temp[:spec] += ' | 新品'
        end
        if temp[:name].match?(/商談中/)
          temp[:name].gsub!('商談中', '')
          temp[:view_option] = 2
        end
        temp[:name].gsub!(/(<>|《》)/, '')

        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = Regexp.last_match(2).gsub(/[^0-9.]/, '').to_f if /(心|芯)間:([0-9\,.]+)/ =~ temp[:spec]
        elsif /プレス/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)t/i =~ temp[:spec]
        elsif /ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /能力:([0-9\,.]+)/i =~ temp[:spec]
        elsif /ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /テーブル:([0-9\,.]+)/i =~ temp[:spec]
        elsif /(コンプレッサ|モーター)/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)kw/i =~ temp[:spec]
        elsif /シャーリング/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(2).gsub(/[^0-9.]/, '').to_f if /(切断寸法|切断長さ|テーブル):([0-9\,.]+)/i =~ temp[:spec]
        elsif /コーナーシャー/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /加工板厚:([0-9\,.]+)/i =~ temp[:spec]
        elsif /スポット溶接/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KVA/i =~ temp[:spec]
        elsif /溶接/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
        elsif /スロッタ/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /エアータンク/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ℓ/i =~ temp[:spec]
        elsif /バンドソー|ダイヤモンドソー/ =~ temp[:name]
          temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ｘ/i =~ temp[:spec]
        elsif temp[:name].match?(/フォークリフト|ローリフト|ホイスト|チェーンブロック|クレーン/)
          if /([0-9\,.]+)t/i =~ temp[:spec]
            temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)kg/i =~ temp[:spec]
            temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f / 1000
          end
        elsif temp[:name].match?(/定.?盤/)
          if /([0-9\,.]+)x([0-9\,.]+)/i =~ temp[:spec]
            le1 = Regexp.last_match(1).to_s.gsub(/[^0-9.]/, '').to_f
            le2 = Regexp.last_match(2).to_s.gsub(/[^0-9.]/, '').to_f

            temp[:capacity] = [le1, le2].max
          end
        end

        # 画像
        temp[:used_imgs] = []
        p2.search('img.sp-image').each do |i|
          temp[:used_imgs] << join_uri(@p.uri, i[:src])
        end

        @d << temp
        @log.debug(temp)

        locks.push lock
      end
    rescue StandardError => e
      error_report("scrape error (#{temp[:uid]})", e)
    end.each(&:join)

    self
  end
end
