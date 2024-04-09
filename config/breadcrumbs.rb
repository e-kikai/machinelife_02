### ユーザ画面 ###
crumb :root do
  link "マシンライフ", "/"
end

### 在庫機械 ###
crumb :large_genre do |large_genre|
  link large_genre.large_genre, "/machines/large_genre/#{large_genre.id}"
  parent :root
end

crumb :genre do |genre|
  link genre.genre, "/machines/genre/#{genre.id}"
  parent :large_genre, genre.large_genre
end

crumb :machine do |machine|
  link machine.full_name, "/machines/#{machine.id}"
  parent :genre, machine.genre
end

### 会社情報 ###
crumb :companies do
  link "出品会社一覧", "/companies/"
  parent :root
end

crumb :company do |company|
  link company.company, "/companies/#{company.id}"
  parent :companies
end

crumb :machines_company do |company|
  link "在庫一覧", "/machines/company/#{company.id}"
  parent :company, company
end

### その他共通 ###
crumb :something do |title|
  link title
  parent :root
end

##########################################
crumb :search do |q|
  link "検索結果", search_path(q:)
  parent :root
end

### 会員ページ ###
crumb :admin_root do
  link "会員ページ", "/admin/"
  parent :root
end

crumb :admin_something do |title|
  link title
  parent :admin_root
end

crumb :mypage_user_edit do
  link "会社情報変更", "/admin/companies/edit"
  parent :admin_root
end

crumb :admin_catalogs do
  link "電子カタログ", "/admin/catalogs"
  parent :admin_root
end

crumb :admin_catalogs_search do |title|
  link "#{title}:検索結果", "/admin/catalogs/search"
  parent :admin_catalogs
end

crumb :admin_machines do
  link "在庫機械一覧", "/admin/machines"
  parent :admin_root
end

crumb :admin_machines_new do
  link "新規在庫機械登録", "/admin/machines/new"
  parent :admin_machines
end

crumb :admin_machines_edit do |machine|
  link "#{machine.full_name} 変更", "/admin/machines/#{machine.id}"
  parent :admin_machines
end

### 管理者ページ ###
crumb :system_root do
  link "管理者ページ", "/system/"
  parent :root
end

crumb :system_something do |title|
  link title
  parent :system_root
end

crumb :system_users do
  link "ユーザ一覧", "/system/users"
  parent :system_root
end

crumb :system_users_new do
  link "新規登録", "/system/users/new"
  parent :system_users
end

crumb :system_users_edit do |user|
  link user.user_name, "/system/users/#{user.id}/edit"
  parent :system_users
end

crumb :system_companies do
  link "会社一覧", "/system/companies/"
  parent :system_root
end

crumb :system_companies_new do
  link "新規登録", "/system/companies/new"
  parent :system_companies
end

crumb :system_companies_edit do |company|
  link company.company, "/system/companies/#{company.id}/edit"
  parent :system_companies
end

crumb :system_bidinfos do
  link "入札会バナー一覧", "/system/bidinfos/"
  parent :system_root
end

crumb :system_bidinfos_new do
  link "新規登録", "/system/bidinfos/new"
  parent :system_bidinfos
end

crumb :system_bidinfos_edit do |bidinfo|
  link bidinfo.bid_name, "/system/bidinfos/#{bidinfo.id}/edit"
  parent :system_bidinfos
end

crumb :system_infos do
  link "事務局からのお知らせ一覧", "/system/infos/"
  parent :system_root
end

crumb :system_infos_new do
  link "新規事務局からのお知らせ", "/system/infos/new"
  parent :system_infos
end

crumb :system_infos_edit do |info|
  link "お知らせ変更", "/system/infos/#{info.id}/edit"
  parent :system_infos
end

crumb :system_xl_genres do
  link "大ジャンル一覧", "/system/xl_genres/"
  parent :system_root
end

crumb :system_xl_genres_new do
  link "新規大ジャンル登録", "/system/xl_genres/new"
  parent :system_xl_genres
end

crumb :system_xl_genres_edit do |xl_genre|
  link "大ジャンル変更", "/system/xl_genres/#{xl_genre.id}/edit"
  parent :system_xl_genres
end

crumb :system_large_genres do |xl_genre|
  link xl_genre.xl_genre, "/system/xl_genres/#{xl_genre.id}"
  parent :system_xl_genres
end

crumb :system_large_genres_new do |xl_genre|
  link "新規中ジャンル登録", "/system/large_genres/new"
  parent :system_large_genres, xl_genre
end

crumb :system_large_genres_edit do |large_genre|
  link "中ジャンル変更", "/system/large_genres/#{large_genre.id}/edit"
  parent :system_large_genres, large_genre.xl_genre
end

crumb :system_genres do |large_genre|
  link large_genre.large_genre, "/system/large_genres/#{large_genre.id}"
  parent :system_large_genres, large_genre.xl_genre
end

crumb :system_genres_new do |large_genre|
  link "新規中ジャンル登録", "/system/genres/new"
  parent :system_genres, large_genre
end

crumb :system_genres_edit do |genre|
  link "中ジャンル変更", "/system/genres/#{genre.id}/edit"
  parent :system_genres, genre.large_genre
end
