xml.instruct! :xml, version: "1.0"
xml.rss(
  version: "2.0",
  "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
  "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
  "xmlns:atom" => "http://www.w3.org/2005/Atom",
  "xmlns:sy" => "http://purl.org/rss/1.0/modules/syndication/",
  "xmlns:slash" => "http://purl.org/rss/1.0/modules/slash/",
  "xmlns:media" => "http://search.yahoo.com/mrss/"
) do
  xml.channel do
    xml.title "マシンライフ｜全機連の中古機械情報サイト"
    xml.description "中古機械のスペシャリスト、全機連会員の中古機械在庫情報を掲載しています"
    xml.link "https://www.zenkiren.net/"
    xml.language "ja-ja"
    xml.ttl "40"
    xml.pubDate @date.beginning_of_day.strftime("%a, %d %b %Y %H:%M:%S %Z")
    xml.copyright "Copyright (c) #{Time.current.year} 全日本機械業連合会 All Rights Reserved."
    xml.atom :link, "href" => "https://www.zenkiren.net/feed.rss", "rel" => "self", "type" => "application/rss+xml"
    xml.image do
      xml.url asset_url("header/logo_machinelife.png")
      xml.title "マシンライフ｜全機連の中古機械情報サイト"
      xml.link "https://www.zenkiren.net/"
    end

    xml.item do
      xml.title "新着情報"
      xml.pubDate @date.beginning_of_day.strftime("%a, %d %b %Y %H:%M:%S %Z")
      xml.link "https://www.zenkiren.net/news/machines/#{@date.strftime('%Y-%m-%d')}"
      xml.guid "https://www.zenkiren.net/news/machines/#{@date.strftime('%Y-%m-%d')}", "isPermaLint" => true
      xml.description do
        xml.cdata!(render "mail_machines")
      end
    end
  end
end
