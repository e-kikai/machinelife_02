#! ruby -Ku
#
# クローラクラス(for 岡部機械株式会社　大阪営業所)のソースファイル
# Author::    川端洋平
# Date::      2019/12/13
# Copyright:: Copyright (c) 2013 川端洋平
#
require File.dirname(__FILE__) + '/base'
require 'csv'

# クローラクラス
class Okabeosaka < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company    = '岡部機械株式会社　大阪営業所'
    @company_id = 5
    # @start_uri  = 'http://58.1.231.206/Okabe/frmokabe.aspx?searchname='
    # @start_uri  = 'https://used.okabekikai.com/StockItemList.aspx?searchname='
    @start_uri  = 'https://usedokabe.com/StockItemList.aspx?searchname='

    @crawl_allow = /^xxxxxxxxxx$/
    @crawl_deny  = nil
  end

  #
  # スクレイピング処理
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'#lblList table tr').each do |m|
      begin
        next if m%'th'

        # 大阪営業所の場合はスキップ
        location = (m%'td:nth(8)').text.f
        next if location =~ /本社|岡山|関東/

        uid = (m%'td:nth(2) a:nth(1)').text.f

        ### UIDが-の場合もスキップ ####
        next if /^(\-)*$/ =~ uid
        # next if /^OK/ !~ uid

        #### 既存情報の場合スキップ ####
        next unless check_uid(uid)

        temp = {
          uid:      uid,
          no:       uid,
          maker:    (m%'td:nth(3)').text.f,
          model:    (m%'td:nth(4)').text.f,
          year:     (m%'td:nth(5)').text.f,
          spec:     (m%'td:nth(6)').text.f,
          location: location,
          addr1:    "大阪府",
          addr2:    "東大阪市",

          used_imgs: [],
        }

        #### ディープクロール ####
        p2 = nokogiri join_uri(@p.uri, m.%('td:nth(2) a')[:href])

        name = (p2/'table.block-contents-a-x__data__table tr:nth(2) td').text.f
        name = (m%'td:nth(2) a:nth(2)').text.f if name == '不明'

        temp[:name]     = name
        temp[:hint]     = name
        temp[:comment]  = (p2/'table.block-contents-a-x__data__table tr:nth(7) td').text.f
        temp[:comment] += " OKB-Q : #{(m%'td:nth(7)').text.f}" if (m%'td:nth(7)').text.f != ""

        (p2 / 'a.block-contents-a-v__thumbs__item__pict').each do |i|
          temp[:used_imgs] << join_uri(@p.uri, i[:href])
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
