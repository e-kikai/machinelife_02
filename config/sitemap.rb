# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.zenkiren.net"

SitemapGenerator::Sitemap.create do
  add '/', priority: 1.0, changefreq: 'daily'

  ### 商品詳細 ###
  Machine.sales.only_machines.pluck(:id).each do |id|
    add "/machines/#{id}", priority: 0.95, changefreq: 'daily'
  end

  Machine.sales.only_tools.pluck(:id).each do |id|
    add "/machines/#{id}", priority: 0.9, changefreq: 'daily'
  end

  ### 新着商品 ###
  add "/news/machines", priority: 0.75, changefreq: 'daily'
  add "/news/tools", priority: 0.7, changefreq: 'daily'

  ### 大ジャンル ###
  LargeGenre.where(xl_genre_id: XlGenre::MACHINE_IDS).pluck(:id).each do |id|
    add "/machines/large_genre/#{id}", priority: 0.75, changefreq: 'daily'
  end

  LargeGenre.where.not(xl_genre_id: XlGenre::MACHINE_IDS).pluck(:id).each do |id|
    add "/machines/large_genre/#{id}", priority: 0.7, changefreq: 'daily'
  end

  ### ジャンル ###
  Genre.pluck(:id).each do |id|
    add "/machines/genre/#{id}", priority: 0.65, changefreq: 'daily'
  end

  ### メーカー ###
  Machine.sales.where.not(maker2: "").distinct.pluck(Arel.sql("COALESCE(makers.maker_master, machines.maker2) as ma")).each do |maker|
    add "/machines/maker/#{maker}", priority: 0.6, changefreq: 'daily'
  end

  ### 出品会社 ###
  Machine.sales.distinct.pluck(:company_id).each do |id|
    add "/companies/#{id}", priority: 0.65, changefreq: 'daily'
    add "/machines/company/#{id}", priority: 0.65, changefreq: 'daily'
  end
end
