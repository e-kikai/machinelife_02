#! ruby -Ku
#
# クローラクラス(for 興和機械)のソースファイル
# Author::    川端洋平
# Date::      2013/02/07
# Copyright:: Copyright (c) 2014 川端洋平
#
require File.dirname(__FILE__) + '/base'

# クローラクラス
class Dainichi < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()

    @company     = '株式会社大日機工'
    @company_id  = 240
    @start_uri   = 'https://dnkk.co.jp/wcshop/products/list?disp_number=50'

    @q      = [
                ['https://dnkk.co.jp/wcshop/products/list?disp_number=50&pageno=2', 2],
                ['https://dnkk.co.jp/wcshop/products/list?disp_number=50&pageno=3', 2],
                ['https://dnkk.co.jp/wcshop/products/list?disp_number=50&pageno=4', 2],
                ['https://dnkk.co.jp/wcshop/products/list?disp_number=50&pageno=5', 2],
              ]

    @crawl_allow = /pageno/
    @crawl_deny  = /xxx/
  end

  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'table tr').each do |m|
      begin
        #### 既存情報の場合スキップ ####
        next unless detail_link = m%'a'

        detail_uri  = detail_link[:href].f
        uid         = detail_uri.gsub(/[^0-9]/, '')

        # next if m%'img[alt=売約済]'
        next if m.text =~ /売却済/
        next unless check_uid(uid)

        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, detail_uri)
        p2 = nokogiri(detail_uri)

        temp = {
          uid:      uid,
          location: "本社",
        }

        (p2/'th').each do |th|
          next unless (th%'+ td')

          td_text = (th%'+ td').text.f

          case th.text.f
          when /在庫番号/; temp[:no]      = td_text
          when /機械名/;   temp[:name]    = td_text
          when /メーカー/; temp[:maker]   = td_text
          when /型式/;     temp[:model]   = td_text
          when /年式/;     temp[:year]    = td_text.gsub(/[^0-9]/, '')
          when /主仕様/;   temp[:spec]    = td_text
          when /価格/;     price          = td_text.gsub(/[^0-9]/, '').to_i
          when /コメント/; temp[:comment] = td_text
          end
        end

        temp[:hint] = temp[:name];

        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $2.gsub(/[^0-9.]/, '').to_f if /(心間|芯間)([0-9\,.]+)/ =~ temp[:spec]
        elsif /プレス/ =~ temp[:name]
          if /([0-9\,.]+)ton(.*)$/i =~ temp[:name]
            temp[:hint] = $2.f
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)ton/i =~ temp[:model] || /([0-9\,.]+)ton/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /φ([0-9\,.]+)/i =~ temp[:spec]
        elsif /(シャーリング|ベンディングロール)/ =~ temp[:name]
          if /切断能力([0-9\,.]+)/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /(コンプレッサ|コンプッレサ)/ =~ temp[:name]
          if /([0-9\,.]+)kw/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /フォークリフト|ローリフト|チェーンブロック|ホイスト|クレーン|リフタ/ =~ temp[:name]
          if /([0-9\,.]+)t/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)トン/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)kg/i =~ temp[:spec]
            temp[:capacity] = ($1.gsub(/[^0-9.]/, '').to_f) / 1000
          end
        elsif /定盤/ =~ temp[:name]
          if /([0-9\,.]+)(×|\*)([0-9\,.]+)(×|\*)?/i =~ temp[:model] + ' ' +  temp[:spec]
            le1 = $1
            le2 = $3

            le1 = le1.gsub(/[^0-9.]/, '').to_f
            le2 = le2.gsub(/[^0-9.]/, '').to_f

            temp[:capacity] = le1 > le2 ? le1 : le2
          end
        end

        # 画像
        temp[:used_imgs] = []
        (p2/'#detail_image_box__slides img').each do |i|
          # log.debug(i.to_s)
          next if i[:src] =~ /(junbi|gif)/
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

  #
  # ページの取得
  # Param:: String uri 取得するURI
  # Return:: self
  #
  def getpage(uri, retcount=@retnum)
    # POST用pageno取得
    if /(.*)\#(.*)/ =~ uri
      @p = @a.post(uri, {:pageno => $2})
    else
      @p = @a.get(uri)
    end

    return self
  rescue => exc
    if (retcount -= 1) > 0
      sleep @retslp
      @log.warn("retry #{retcount} : #{uri}")
      mechanize_init
      retry
    else
      raise
    end
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
      href = join_uri(uri, a[:href])

      # POST用にページ番号取得
      next unless a[:onclick]
      if /fnNaviPage\(\'([0-9]*)\'\)/ =~ a[:onclick]
        href += '#' + $1
      end

      if check_uri(href)
        @q << [href, de]
        @v << href
      end
    end

    return self
  end

end
