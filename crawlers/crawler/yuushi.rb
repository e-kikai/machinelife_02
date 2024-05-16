#! ruby -Ku
#
# クローラクラス(for 三善機械)のソースファイル
# Author::    川端洋平
# Date::      2013/01/20
# Copyright:: Copyright (c) 2013 川端洋平
#
require "#{File.dirname(__FILE__)}/base"
require 'csv'

# クローラクラス
class Yuushi < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize
    # 親クラスのコンストラクタ
    super

    @company    = '株式会社ユウシ'
    @company_id = 25
    @start_uri = "https://www.chuuko-kikai.com/item-list.php"
    @crawl_allow = /xxxxx/
    @crawl_deny  = //
  end

  #
  # スクレイピング処理
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    @p = nokogiri(@start_uri)

    @p.search('.wb-blog-list').each do |m|
      uid = m.at('.number').text.f.delete("管理番号")

      next unless check_uid(uid)

      #### ディープクロール ####
      link = m.at('a[href*=blog_id1]')
      detail_uri = join_uri(@start_uri, link[:href])

      begin
        p2 = nokogiri(detail_uri)

        temp = {
          uid:,
          no: uid,
          name: "",
          maker: "",
          location: "本社"
        }

        p2.search(".item-detail-table tr").each do |tr|
          td = tr.at("td").text.f
          case tr.at("th").text.f
          when "機械名"; temp[:name] = td
          when "メーカー"; temp[:maker] = td
          when "型式"; temp[:model] = td
          when "年式"; temp[:year] = td
          when "仕様"; temp[:spec] = td
          when "付属品"; temp[:accessory] = td
          when "コメント"; temp[:comment] = td
          end

          temp[:hint] = temp[:name].gsub(/(（.*)$/, "")
        end

        next if temp[:maker].include?("●")

        # 画像
        temp[:used_imgs] = p2.search('.img-sub img').filter_map do |i|
          next unless i[:src].match?(/(jpg|JPG|jpeg|JPEG)$/)
          next if i[:src].include?("image_noimage")

          join_uri(detail_uri, i[:src])
        end

        @d << temp if temp[:name]
        @log.debug(temp)
      rescue StandardError => e
        error_report("scrape error (#{uid || 0})", e)
        next
      end
    end

    self
  end
end
