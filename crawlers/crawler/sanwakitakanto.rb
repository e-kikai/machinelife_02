#! ruby -Ku
#
# クローラクラス(for 三和精機)のソースファイル
# Author::    川端洋平
# Date::      2012/5/17
# Copyright:: Copyright (c) 2012 川端洋平
#
require  File.dirname(__FILE__) + '/base'

# クローラクラス
class Sanwakitakanto < Base

  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company    = '三和精機株式会社北関東営業所'
    @company_id = 62
    # @start_uri  = 'http://www.sanwaseiki.com/component/machinelist/?category=1'
    @start_uri  = 'http://sanwa-seiki.jp/machinelist/item/100'

    # @crawl_allow = /machinelist\/\?category/
    @crawl_allow = /machinelist\/item/
    @crawl_deny  = nil
  end

  #
  # クロールキューにURLを追加
  # Param:: Int depth クロール深度
  # Return:: self
  #
  def append_quere(de)
    # クロールキューにURIを追加
    uri = @a.page.uri
    (@a.page/"a").each do |a|
      href = join_uri(uri, a[:page])
      if check_uri(href)
        @q << [href, de]
        @v << href
      end
    end

    return self
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'table#item_list_table tr').each do |m|
      begin
        next unless m%'td:nth(2) a'

        # 「本社」のもの以外スキップ
        location = (m%'td:nth(8)').text.f

        next if location != '北関東営業所'

        #### 既存情報の場合スキップ ####
        href = (m%'td:nth(2) a')[:href].f
        uid  = $1 if /item_detail\/([0-9]+)/ =~ href
        next unless check_uid(uid)

        temp = {
          :uid   => uid,
          :no    => (m%'td:nth(1)').text.f.gsub(/[^0-9a-zA-Z]/, ''),
          :name  => (m%'td:nth(3)').text.f,
          :maker => (m%'td:nth(4)').text.f,
          :model => (m%'td:nth(5)').text.f,
          :year  => (m%'td:nth(6)').text.f,
          :spec  => (m%'td:nth(7)').text.f,
          :location => "北関東",
        }
        temp[:hint] = temp[:name]

        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /芯間\s*([0-9.,]+)mm/ =~ temp[:spec]
        elsif /ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /プレス/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)ton/i =~ temp[:spec]
        elsif /(コンプレッサ|モーター)/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)Kw/i =~ temp[:spec]
        elsif /チェーンブロック|ホイスト|フォークリフト/ =~ temp[:name]
          if /([0-9\,.]+)t(.*)$/i =~ temp[:name]
            temp[:hint]     = $2.to_s.f
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /タンク/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)リットリ/i =~ temp[:spec]
        end

        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, href)
        p2 = nokogiri(detail_uri)

        # 画像
        temp[:used_imgs] = []
        (p2/'#slider img').each do |i|
          next if /no_img/ =~ i[:src]
          temp[:used_imgs] << join_uri(detail_uri, i[:src])
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
