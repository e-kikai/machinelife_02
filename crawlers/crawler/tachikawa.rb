#! ruby -Ku
#
# クローラクラス(for 立川商店)のソースファイル
# Author::    川端洋平
# Date::      2013/02/07
# Copyright:: Copyright (c) 2013 川端洋平
#
require "#{File.dirname(__FILE__)}/base"

# クローラクラス
class Tachikawa < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize
    # 親クラスのコンストラクタ
    super()

    @company    = '有限会社立川商店'
    @company_id = 13
    @start_uri  = 'https://tachikawa-kikai.com/stocks'

    @crawl_allow = %r{(page|/tool_shop)}
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    ### ページ情報のスクレイピング ###
    locks = Queue.new
    5.times { locks.push :lock }

    # ツールショップと処理分割
    threads2 =
      if @p.uri.to_s.include?('tool_shop')
        @p.search('tr').filter_map do |m|
          # スキップ
          link = m.search('td:nth(3) a')
          next if link.empty?

          detail_uri = link.first[:href].f
          uid        = link.first.text.f

          next unless check_uid(uid)

          Thread.new do
            lock = locks.pop

            temp = {
              uid:,
              no: uid,
              location: "ツールショップ寿"
            }
            price = 0

            ### ディープクロール ###
            detail_uri = join_uri(@p.uri, detail_uri)
            p2 = nokogiri(detail_uri)

            p2.search('dt').each do |dt|
              next unless dt.at('+ dd')

              dd_text = dt.at('+ dd').text.f
              next if dd_text.empty?

              case dt.text.f
              when /機械名/; temp[:name] = dd_text
              # when /機械カテゴリ/; temp[:hint]  = dd_text
              when /メーカー/; temp[:maker] = dd_text
              when /型番/; temp[:model] = dd_text
              when /年式/; temp[:year]  = dd_text
              when /仕様/; temp[:spec]  = dd_text
              when /価格/; price        = dd_text.gsub(/[^0-9]/, '').to_i
              when /コメント/; temp[:comment] = dd_text
              end
            end

            temp[:hint] = temp[:name]

            # 販売価格
            if (1..100_000_000).cover?(price)
              temp[:price]        = price
              temp[:ekikai_price] = price
            end

            # 画像
            temp[:used_imgs] = p2.search('img.slide-photo').filter_map { |i| i[:src] }

            @d << temp
            @log.debug(temp)

            locks.push lock
          rescue StandardError => e
            error_report("scrape error (#{temp[:uid]})", e)
          end
        end
      else
        @p.search('a.all-machine').filter_map do |m|
          # スキップ
          detail_uri = m[:href].f
          next unless m.search('dd')

          uid = m.search('dd').first.text.f
          next unless check_uid(uid)

          Thread.new do
            lock = locks.pop

            temp = {
              uid:,
              no: uid,
              location: "関東組合"
            }
            price = 0

            m.search('dt').each do |dt|
              next unless dt.at('+ dd')

              dd_text = dt.at('+ dd').text.f
              next if dd_text.empty?

              case dt.text.f
              when /機械名/; temp[:name] = dd_text
              when /メーカー/; temp[:maker] = dd_text
              when /型番/; temp[:model] = dd_text
              when /年式/; temp[:year]  = dd_text
              when /価格/; price        = dd_text.gsub(/[^0-9]/, '').to_i
              end
            end

            temp[:hint] = temp[:name]

            ### ディープクロール ###
            detail_uri = join_uri(@p.uri, detail_uri)
            p2 = nokogiri(detail_uri)

            @p.search('dt').each do |dt|
              next unless dt.at('+ dd')

              dd_text = dt.at('+ dd').text.f
              next if dd_text.empty?

              case dt.text.f
              when /仕様/; temp[:spec] = dd_text
              when /コメント/; temp[:comment] = dd_text
              end
            end

            # 販売価格
            if (1..100_000_000).cover?(price)
              temp[:price]        = price
              temp[:ekikai_price] = price
            end

            # 主能力
            if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
              if /([3-9])尺/ =~ temp[:name]
                temp[:capacity] = LATER_CAP[Regexp.last_match(1).to_i]
              elsif /([0-9.]+)m/ =~ temp[:name]
                temp[:capacity] = Regexp.last_match(1).to_f * 1000
              end
            elsif /プレス/ =~ temp[:name]
              temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)T/i =~ temp[:spec]
            elsif /ベンダ|ボール盤/ =~ temp[:name] && temp[:name].exclude?('NC')
              temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
            elsif temp[:name].include?("コンプレッサ")
              if /([0-9\,.]+)KW(.*)$/i =~ temp[:name]
                temp[:hint] = Regexp.last_match(2)
                temp[:capacity] = Regexp.last_match(1).gsub(/[^0-9.]/, '').to_f
              end
            elsif temp[:name].include?("定盤")
              if /([0-9\,.]+)×([0-9\,.]+)/i =~ temp[:model]
                le1 = Regexp.last_match(1).to_s.gsub(/[^0-9.]/, '').to_f
                le2 = Regexp.last_match(2).to_s.gsub(/[^0-9.]/, '').to_f

                temp[:capacity] = [le1, le2].max
              end
            end

            # 画像
            temp[:used_imgs] = p2.search('img.slide-photo').filter_map { |i| i[:src] }

            @d << temp
            @log.debug(temp)

            locks.push lock
          rescue StandardError => e
            error_report("scrape error (#{temp[:uid]})", e)
          end
        end
      end

    ### スレッドを結合 ###
    threads2.each(&:join)

    self
  end
end
