#! ruby -Ku
#
# クローラクラス(for 興和機械)のソースファイル
# Author::    川端洋平
# Date::      2013/02/07
# Copyright:: Copyright (c) 2014 川端洋平
#
require File.dirname(__FILE__) + '/base'

# クローラクラス
class Kowa < Base
  #
  # コンストラクタ
  # Param:  Hash site クロール対象サイト情報
  #
  def initialize()
    # 親クラスのコンストラクタ
    super()
    
    @company    = '興和機械株式会社'
    @company_id = 189
    @start_uri  = 'http://www.kowakikai.jp/products/'
    
    @crawl_allow = /products\/category/
    @crawl_deny  = nil
  end
  
  #
  # スクレイピング処理
  # Param:: String uri URI
  # Return:: self
  #  
  def scrape
    #### ページ情報のスクレイピング ####
    (@p/'.top-item-list .one-fix').each do |m|
      begin
        #### 既存情報の場合スキップ ####
        detail_link = m%'.img a'
        detail_uri  = detail_link[:href].f
        uid         = (m%'.no-base p').text.f
        next unless check_uid(uid)
        
        #### ディープクロール ####
        detail_uri = join_uri(@p.uri, detail_uri)
        p2 = nokogiri(detail_uri)
        
        temp = {
          :uid       => uid,
          :no        => uid,
          :name      => (p2%'.deta-table tr:nth(2) td').text.f,
          :hint      => (p2%'.deta-table tr:nth(2) td').text.f,
          :maker     => (p2%'.deta-table tr:nth(3) td').text.f,
          :model     => (p2%'.deta-table tr:nth(4) td').text.f,
          :year      => (p2%'.deta-table tr:nth(5) td').text.f.gsub(/[^0-9]/, ''),
          :spec      => (p2%'.deta-table-02 tr:nth(1) td').text.f,
          :location  => (p2%'.deta-table-02 tr:nth(3) td').text.f,
          :used_pdfs => {},
          :used_imgs => [],
        }

        if /^([0-9]+)(万円)$/ =~ (p2%'.deta-table-02 tr:nth(2) td').text.f
          temp[:price] = $1.to_i * 10000
        end
        
        # 主能力
        if /旋盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $2.gsub(/[^0-9.]/, '').to_f if /(芯間\:|\*)([0-9\,.]+)/ =~ temp[:spec]
        elsif /プレス/ =~ temp[:name]
          if /([0-9\,.]+)T(.*)$/i =~ temp[:name]
            temp[:hint] = $2.f
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)T/i =~ temp[:model] || /([0-9\,.]+)T/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f 
          end
        elsif /ベンダー/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /ボール盤/ =~ temp[:name] && /NC/ !~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)mm/i =~ temp[:spec]
        elsif /(シャーリング|ベンディングロール)/ =~ temp[:name]
          if /\*([0-9\,.]+)/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)mm/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)m×/i =~ temp[:spec]
            temp[:capacity] = ($1.gsub(/[^0-9.]/, '').to_f) * 1000
          elsif /([0-9\,.]+)m×/i =~ temp[:name]
            temp[:capacity] = ($1.gsub(/[^0-9.]/, '').to_f) * 1000
          end
        elsif /(コンプレッサ|コンプッレサ)/ =~ temp[:name]
          if /([0-9\,.]+)KW(.*)$/i =~ temp[:name]
            temp[:hint] = $2.f
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)KW/i =~ temp[:spec]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          end
        elsif /スポット溶接/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)KVA/i =~ temp[:spec]
        elsif /溶接/ =~ temp[:name]
          temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f if /([0-9\,.]+)A/i =~ temp[:spec]
        elsif /フォークリフト|ローリフト|チェーンブロック|ホイスト|クレーン|リフタ/ =~ temp[:name]
          if /([0-9\,.]+)t/i =~ temp[:model]
            temp[:capacity] = $1.gsub(/[^0-9.]/, '').to_f
          elsif /([0-9\,.]+)t/i =~ temp[:spec]
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
        (p2/'#imageList img').each do |i|
          temp[:used_imgs] << 'http://www.kowakikai.jp' + i[:src]
        end

        # PDF
        (p2/'.deta-table-02 tr:nth(4) td a').each do |i|
          temp[:used_pdfs]['仕様書'] = 'http://www.kowakikai.jp' + i[:href]
        end

        # youtube
        temp[:youtube] = nil
        (p2/'iframe').each do |i|
          temp[:youtube] = 'http://youtu.be/' + i[:src].gsub(/^(.*\/)/, '')
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
  # クロールメソッド
  # Param:: String url クロール開始URL
  # Param:: Integer depth 初期クロール深度
  # Return:: self
  #
  def crawl()
    # クロールキューにスタートURIを追加
    @q << [@start_uri, 1]
    
    #### クロールループ ####
    50.times do |i|
      uri = 'http://www.kowakikai.jp/products/'
      
      begin
        getpage(uri, i) # ページの取得
        scrape       # スクレイピング
      rescue => exc
        error_report("getpage error", exc)
      end
    end
    
    # エラーログをメールで送信(あれば)
    send_error
      
    return self
  rescue => exc
    error_report("crawl error", exc)
    # エラーログをメールで送信
    send_error
    
    @log.error("error exit")
    return false
  end

  #
  # ページの取得
  # Param:: String uri 取得するURI
  # Return:: self
  #
  def getpage(uri, i, retcount=@retnum)
    @p = @a.post(uri, {offset: 12 * i})
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
end
