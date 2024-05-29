# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_05_27_102853) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_history_logs", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.integer "company_id"
    t.text "utag", default: "", null: false
    t.text "ip", default: "", null: false
    t.text "host", default: "", null: false
    t.text "event", default: "", null: false
    t.jsonb "datas", default: {}, null: false
    t.text "referer", default: "", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.text "page"
    t.boolean "is_system", default: false
  end

  create_table "bid_bids", id: { type: :serial, comment: "入札ID" }, comment: "入札会入札情報", force: :cascade do |t|
    t.integer "bid_machine_id", null: false, comment: "入札商品ID"
    t.integer "company_id", null: false, comment: "会社ID"
    t.integer "amount", null: false, comment: "入札金額"
    t.text "charge", null: false, comment: "担当者"
    t.text "comment", comment: "備考欄"
    t.integer "sameno", comment: "同額ナンバー"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.index ["bid_machine_id"], name: "bid_bids_ix1"
    t.index ["company_id"], name: "bid_bids_ix2"
  end

  create_table "bid_detail_logs", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.integer "bid_machine_id", null: false
    t.integer "my_user_id"
    t.text "utag"
    t.text "ip"
    t.text "host"
    t.text "r", default: ""
    t.text "referer"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
  end

  create_table "bid_machines", id: { type: :serial, comment: "機械ID" }, comment: "入札会商品情報", force: :cascade do |t|
    t.integer "bid_open_id", null: false, comment: "入札会ID"
    t.integer "list_no", comment: "リストNo"
    t.integer "machine_id", comment: "機械ID"
    t.text "name", comment: "機械名"
    t.integer "genre_id", null: false, comment: "ジャンルID"
    t.text "maker", comment: "メーカー"
    t.text "model", comment: "型式"
    t.text "year", comment: "年式"
    t.float "capacity", comment: "能力"
    t.text "others", comment: "その他能力(JSON)\t JSON"
    t.text "accessory", comment: "附属品\t 2012/08/17"
    t.text "spec", comment: "仕様"
    t.text "comment", comment: "コメント\t 2012/08/17"
    t.text "location", comment: "在庫場所"
    t.integer "min_price", comment: "入札最低金額"
    t.integer "company_id", null: false, comment: "会社ID"
    t.text "top_img", comment: "トップ画像\t 2012/08/17"
    t.text "imgs", comment: "画像情報(JSON)\t JSON"
    t.text "pdfs", comment: "PDF(JSON)\t JSON"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.integer "commission", comment: "試運転"
    t.text "youtube", comment: "YoutubeID"
    t.text "addr1", comment: "住所(都道府県)"
    t.text "addr2", comment: "住所(市区町村)"
    t.text "addr3", comment: "住所(番地その他)"
    t.decimal "lat", precision: 10, scale: 7, comment: "緯度"
    t.decimal "lng", precision: 10, scale: 7, comment: "経度"
    t.text "carryout_note", comment: "引取留意事項"
    t.integer "seri_price"
    t.integer "prompt", default: 0
    t.datetime "canceled_at", precision: nil
    t.text "cancel_comment"
    t.integer "shipping", default: 0
    t.text "shipping_comment", default: ""
    t.datetime "auto_at", precision: nil
    t.integer "star"
    t.index ["bid_open_id"], name: "bid_machines_ix6"
    t.index ["company_id"], name: "bid_machines_ix4"
    t.index ["created_at"], name: "bid_machines_ix5"
    t.index ["deleted_at"], name: "bid_machines_ix1"
    t.index ["genre_id"], name: "bid_machines_ix2"
    t.index ["list_no", "bid_open_id"], name: "bid_machines_ix7"
    t.index ["maker"], name: "bid_machines_ix3"
  end

  create_table "bid_opens", id: { type: :serial, comment: "入札会ID" }, comment: "入札会開催情報", force: :cascade do |t|
    t.text "title", comment: "タイトル"
    t.text "organizer", comment: "主催者名"
    t.datetime "entry_start_date", precision: nil, comment: "出品開始日時"
    t.datetime "entry_end_date", precision: nil, comment: "出品終了日時"
    t.datetime "bid_start_date", precision: nil, comment: "入札開始日時"
    t.datetime "bid_end_date", precision: nil, comment: "入札終了日時"
    t.datetime "billing_date", precision: nil, comment: "請求日"
    t.datetime "payment_date", precision: nil, comment: "支払日"
    t.datetime "carryout_start_date", precision: nil, comment: "搬出開始日"
    t.datetime "carryout_end_date", precision: nil, comment: "搬出終了日"
    t.datetime "display_start_date", precision: nil, comment: "表示開始日時"
    t.datetime "display_end_date", precision: nil, comment: "表示終了日時"
    t.integer "min_price", comment: "最低入札金額"
    t.integer "rate", comment: "入札レート"
    t.integer "tax", comment: "消費税(%)"
    t.integer "motobiki", comment: "元引き手数料"
    t.integer "deme", comment: "デメ"
    t.integer "fee_calc", comment: "手数料計算"
    t.integer "entry_limit_style", comment: "出品点数制限方法"
    t.integer "entry_limit_num", comment: "出品点数制限数"
    t.text "entry_limit_company_id", comment: "出品会社制限"
    t.text "bid_limit_company_id", comment: "入札会社制限"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.text "announce_list", comment: "リストお知らせ"
    t.integer "sashizu_flag", comment: "指図書フラグ"
    t.datetime "preview_start_date", precision: nil, comment: "下見期間開始日時"
    t.datetime "preview_end_date", precision: nil, comment: "下見期間終了日時"
    t.datetime "user_bid_date", precision: nil, comment: "入札日時(一般ユーザ向け)"
    t.text "list_pdf"
    t.datetime "seri_start_date", precision: nil
    t.datetime "seri_end_date", precision: nil
    t.index ["deleted_at"], name: "bid_opens_ix1"
  end

  create_table "bidinfos", id: { type: :serial, comment: "情報ID" }, comment: "入札会情報", force: :cascade do |t|
    t.text "bid_name", comment: "入札会名"
    t.text "organizer", comment: "主催者名"
    t.text "place", comment: "開催場所"
    t.text "comment", comment: "コメント"
    t.datetime "bid_date", precision: nil, comment: "入札日時"
    t.date "preview_start_date", comment: "下見開始日"
    t.date "preview_end_date", comment: "下見終了日"
    t.text "banner_file", comment: "バナーファイル"
    t.text "uri", comment: "リンク先"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.string "banner_image"
    t.index ["bid_date"], name: "bidinfos_ix3"
    t.index ["preview_end_date"], name: "bidinfos_ix2"
    t.index ["preview_start_date"], name: "bidinfos_ix1"
  end

  create_table "c_keywords", id: { type: :serial, comment: "キーワードID" }, comment: "カタログ検索キーワード", force: :cascade do |t|
    t.integer "catalog_id", null: false, comment: "カタログID"
    t.text "keyword", null: false, comment: "キーワード"
    t.index ["keyword"], name: "c_keywords_ix1"
  end

  create_table "catalog_genre", id: { type: :serial, comment: "リレーションID" }, comment: "カタログ、ジャンルリレーション", force: :cascade do |t|
    t.integer "catalog_id", null: false, comment: "カタログID"
    t.integer "genre_id", null: false, comment: "ジャンルID"
    t.index ["catalog_id", "genre_id"], name: "catalog_genre_ix3", unique: true
    t.index ["catalog_id"], name: "catalog_genre_ix1"
    t.index ["genre_id"], name: "catalog_genre_ix2"
  end

  create_table "catalog_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "catalog_id"
    t.string "utag", default: ""
    t.string "ip", default: ""
    t.string "host", default: ""
    t.string "ua", default: ""
    t.string "referer", default: ""
    t.string "r", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_id"], name: "index_catalog_logs_on_catalog_id"
    t.index ["user_id"], name: "index_catalog_logs_on_user_id"
  end

  create_table "catalog_requests", primary_key: "request_id", id: { type: :serial, comment: "リクエストID" }, comment: "カタログリクエスト", force: :cascade do |t|
    t.text "target", comment: "対象"
    t.text "maker", comment: "メーカー"
    t.text "model", comment: "型式"
    t.text "comment", comment: "コメント"
    t.integer "send_count", comment: "送信数"
    t.integer "user_id", comment: "ユーザID"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.index ["comment"], name: "catalog_requests_ix1"
    t.index ["user_id"], name: "catalog_requests_ix2"
  end

  create_table "catalogs", id: { type: :serial, comment: "カタログID" }, comment: "カタログ", force: :cascade do |t|
    t.text "uid", null: false, comment: "ユニークキー"
    t.text "file", comment: "カタログファイル名\t PDFファイル名"
    t.text "thumbnail", comment: "サムネイル画像ファイル名"
    t.text "maker", comment: "メーカー"
    t.text "maker_kana", comment: "メーカー(カナ)\t テキスト用"
    t.text "year", comment: "年代"
    t.text "models", comment: "型式群"
    t.text "keywords", comment: "検索キーワード\t 部分一致"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.text "catalog_no"
    t.index ["maker"], name: "catalogs_ix2"
    t.index ["models"], name: "catalogs_ix1"
  end

  create_table "companies", id: { type: :serial, comment: "会社ID" }, comment: "掲載会社", force: :cascade do |t|
    t.text "company", comment: "会社名"
    t.text "company_kana", comment: "会社名（カナ）"
    t.text "officer", comment: "担当者名"
    t.text "zip", comment: "郵便番号"
    t.text "addr1", comment: "住所"
    t.text "mail", comment: "メールアドレス"
    t.text "tel", comment: "TEL"
    t.text "fax", comment: "FAX"
    t.text "website", comment: "ウェブサイトアドレス"
    t.text "infos", comment: "情報(JSON)\t 項目は設定ファイルで"
    t.text "top_img", comment: "トップ画像"
    t.text "imgs", comment: "画像情報(JSON)"
    t.datetime "created_at", precision: nil, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.text "offices", comment: "営業所情報(JSON)"
    t.text "addr2", comment: "住所(市区町村)"
    t.text "addr3", comment: "住所(番地その他)"
    t.decimal "lat", precision: 10, scale: 7, comment: "緯度"
    t.decimal "lng", precision: 10, scale: 7, comment: "経度"
    t.integer "group_id", comment: "団体ID"
    t.text "contact_mail", comment: "問い合わせメールアドレス"
    t.text "contact_tel", comment: "問い合わせTEL"
    t.text "contact_fax", comment: "問い合わせFAX"
    t.text "representative", comment: "代表者"
    t.text "bid_entries", comment: "入札会出品登録"
    t.integer "rank", default: 0
    t.integer "parent_company_id"
    t.integer "ekikai_id"
    t.text "ekikai_subdomain"
    t.integer "ekikai_order"
    t.string "top_image"
  end

  create_table "company_images", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.text "image", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_images_on_company_id"
    t.index ["deleted_at"], name: "index_company_images_on_deleted_at"
  end

  create_table "companybid_machines", primary_key: "companybid_machine_id", id: :serial, force: :cascade do |t|
    t.integer "companybid_open_id"
    t.text "list_no"
    t.text "name"
    t.integer "genre_id"
    t.text "maker"
    t.text "model"
    t.text "year"
    t.text "spec"
    t.text "location"
    t.integer "min_price"
    t.text "min_price_comment"
    t.text "imgs"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.text "pdfs"
  end

  create_table "companybid_opens", primary_key: "companybid_open_id", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.text "title"
    t.text "preview_locations"
    t.date "preview_start_date"
    t.date "preview_end_date"
    t.text "preview_date_comment"
    t.text "bid_location"
    t.text "bid_address"
    t.text "bid_comment"
    t.datetime "bid_date", precision: nil
    t.text "bid_date_comment"
    t.text "comment"
    t.text "pdf_files"
    t.text "img_file"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
  end

  create_table "companysites", primary_key: "companysite_id", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.text "subdomain"
    t.text "contents"
    t.text "page_configs"
    t.text "company_configs"
    t.text "template"
    t.integer "closed"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
  end

  create_table "contacts", id: { type: :serial, comment: "問い合わせID" }, comment: "問い合わせ", force: :cascade do |t|
    t.integer "machine_id", comment: "機械ID"
    t.integer "company_id", comment: "会社ID"
    t.integer "user_id", comment: "ユーザID\t 問い合わせユーザ"
    t.text "user_name", comment: "ユーザ名\t 問い合わせユーザ"
    t.text "mail", comment: "メールアドレス"
    t.text "tel", comment: "TEL"
    t.text "fax", comment: "FAX"
    t.text "message", comment: "内容"
    t.integer "return", comment: "連絡方法\t JSON"
    t.text "return_time", comment: "時間帯"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.text "addr1"
    t.text "user_company"
    t.integer "mailuser_flag"
    t.index ["company_id"], name: "contacts_company_id_idx"
    t.index ["company_id"], name: "contacts_ix1"
  end

  create_table "d_infos", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.date "info_date"
    t.string "title", limit: 255
    t.text "contents"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil, default: -> { "now()" }
    t.datetime "deleted_at", precision: nil
  end

  create_table "detail_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "machine_id"
    t.string "utag", default: ""
    t.string "ip", default: ""
    t.string "host", default: ""
    t.string "ua", default: ""
    t.string "referer", default: ""
    t.string "r", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_detail_logs_on_machine_id"
    t.index ["user_id"], name: "index_detail_logs_on_user_id"
  end

  create_table "eipses", id: { type: :serial, comment: "EIPS ID" }, comment: "EIPS", force: :cascade do |t|
    t.integer "site_id", null: false, comment: "サイトID"
    t.text "name", comment: "機械名"
    t.integer "maker", comment: "メーカー"
    t.text "model", comment: "型式"
    t.text "year", comment: "年式"
    t.text "spec", comment: "仕様"
    t.text "location", comment: "在庫場所"
    t.text "company", comment: "登録企業"
    t.text "detail_url", comment: "詳細URL"
    t.text "imgs", comment: "画像ファイル名群"
    t.text "ref_url", comment: "情報参照URL"
    t.text "uid", default: "0", comment: "ユニークキー"
    t.text "company_url", comment: "会社ページURL"
    t.text "toiawase_url", comment: "問い合わせURL"
    t.integer "genre_id", comment: "ジャンルID"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.index ["created_at"], name: "eipses_ix2"
    t.index ["deleted_at"], name: "eipses_ix1"
    t.index ["genre_id"], name: "eipses_ix3"
    t.index ["site_id"], name: "eipses_ix4"
  end

  create_table "genre_hints", id: { type: :serial, comment: "ヒントID" }, comment: "ジャンル振分ヒントマスタ", force: :cascade do |t|
    t.integer "site_id", null: false, comment: "サイトID"
    t.integer "genre_id", null: false, comment: "ジャンルID"
    t.text "hint", comment: "ヒントキーワード"
    t.index ["site_id", "hint"], name: "idx_genre_hint_site_id_hint"
  end

  create_table "genre_matchings", id: { type: :integer, comment: "マッチングID", default: nil }, comment: "ジャンルマッチングマスタ", force: :cascade do |t|
    t.integer "genre_id", null: false, comment: "ジャンルID"
    t.text "column", comment: "マッチング対象カラム\t name"
    t.text "allow", comment: "許可正規表現"
    t.text "deny", comment: "拒否正規表現"
    t.index ["genre_id"], name: "idx_genre_matching_genre_id"
  end

  create_table "genres", id: { type: :serial, comment: "ジャンルID" }, comment: "ジャンルマスタ", force: :cascade do |t|
    t.integer "large_genre_id", null: false, comment: "大ジャンルID"
    t.text "genre", comment: "ジャンル名"
    t.text "genre_kana", comment: "ジャンル名（カナ）"
    t.text "capacity_label", comment: "能力項目名"
    t.text "capacity_unit", comment: "能力単位"
    t.text "spec_labels", comment: "その他能力項目(JSON)\t JSON"
    t.text "naming", comment: "命名規則"
    t.integer "order_no", comment: "並び順"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.index ["large_genre_id"], name: "genres_ix1"
  end

  create_table "groups", id: { type: :serial, comment: "団体ID" }, comment: "団体", force: :cascade do |t|
    t.integer "parent_id", comment: "親団体ID"
    t.text "groupname", comment: "団体名"
    t.datetime "created_at", precision: nil, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.index ["parent_id"], name: "groups_ix1"
  end

  create_table "infos", id: { type: :serial, comment: "ID" }, comment: "事務局お知らせ", force: :cascade do |t|
    t.string "target", limit: 200, comment: "対象"
    t.date "info_date", comment: "表示日付"
    t.text "contents", comment: "内容"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.integer "group_id", comment: "団体ID"
    t.index ["info_date"], name: "infos_ix1"
  end

  create_table "large_genre_maker", id: { type: :serial, comment: "リレーションID" }, comment: "大ジャンル、メーカーリレーション", force: :cascade do |t|
    t.integer "large_genre_id", null: false, comment: "大ジャンルID"
    t.integer "maker_id", null: false, comment: "メーカーID"
    t.index ["large_genre_id", "maker_id"], name: "large_genre_maker_ix3", unique: true
    t.index ["large_genre_id"], name: "large_genre_maker_ix1"
    t.index ["maker_id"], name: "large_genre_maker_ix2"
  end

  create_table "large_genres", id: { type: :serial, comment: "大ジャンルID" }, comment: "大ジャンルマスタ", force: :cascade do |t|
    t.text "large_genre", comment: "大ジャンル名"
    t.text "large_genre_kana", comment: "大ジャンル名（カナ）"
    t.integer "order_no", comment: "並び順"
    t.integer "hide_option", comment: "非表示オプション"
    t.integer "xl_genre_id", comment: "特大ジャンルID"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
  end

  create_table "machine_images", force: :cascade do |t|
    t.bigint "machine_id", null: false
    t.text "image", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_machine_images_on_deleted_at"
    t.index ["machine_id"], name: "index_machine_images_on_machine_id"
  end

  create_table "machine_nitamonos", force: :cascade do |t|
    t.integer "machine_id", null: false
    t.integer "nitamono_id", null: false
    t.float "norm", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }, null: false
    t.datetime "soft_destroyed_at", precision: nil
    t.index ["machine_id", "nitamono_id"], name: "index_machine_nitamonos_on_machine_id_and_nitamono_id", unique: true
    t.index ["machine_id"], name: "index_machine_nitamonos_on_machine_id"
    t.index ["nitamono_id"], name: "index_machine_nitamonos_on_nitamono_id"
    t.index ["soft_destroyed_at"], name: "index_machine_nitamonos_on_soft_destroyed_at"
  end

  create_table "machine_pdfs", force: :cascade do |t|
    t.bigint "machine_id", null: false
    t.string "pdf", null: false
    t.string "name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_machine_pdfs_on_deleted_at"
    t.index ["machine_id"], name: "index_machine_pdfs_on_machine_id"
  end

  create_table "machines", id: { type: :serial, comment: "機械ID" }, comment: "在庫機械", force: :cascade do |t|
    t.text "no", comment: "管理番号"
    t.string "name", limit: 100, comment: "機械名"
    t.integer "genre_id", null: false, comment: "ジャンルID"
    t.text "maker", comment: "メーカー"
    t.text "model", comment: "型式"
    t.text "year", comment: "年式"
    t.float "capacity", comment: "能力"
    t.text "others", comment: "その他能力(JSON)\t JSON"
    t.text "spec", comment: "仕様"
    t.text "location", comment: "在庫場所"
    t.integer "company_id", null: false, comment: "会社ID"
    t.integer "catalog_id", comment: "カタログID"
    t.text "top_img", comment: "トップ画像"
    t.text "imgs", comment: "画像情報(JSON)\t JSON"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.text "accessory", comment: "附属品"
    t.text "comment", comment: "コメント"
    t.text "pdfs", comment: "PDF(JSON)"
    t.integer "view_option", comment: "表示オプション"
    t.integer "commission", comment: "試運転"
    t.text "location_address", comment: "在庫場所住所"
    t.text "youtube", comment: "Youtube ID"
    t.text "addr1", comment: "住所(都道府県)"
    t.text "addr2", comment: "住所(市区町村)"
    t.text "addr3", comment: "住所(番地その他)"
    t.decimal "lat", precision: 10, scale: 7, comment: "緯度"
    t.decimal "lng", precision: 10, scale: 7, comment: "経度"
    t.integer "price", comment: "金額"
    t.string "used_id", limit: 200
    t.integer "price_tax"
    t.string "hint", limit: 200
    t.integer "used_change"
    t.integer "ekikai_price"
    t.virtual "model2", type: :string, as: "regexp_replace(upper(model), '[^A-Z0-9]+'::text, ''::text, 'g'::text)", stored: true
    t.virtual "maker2", type: :string, as: "TRIM(BOTH FROM regexp_replace(\nCASE\n    WHEN ((maker = '-'::text) OR (maker IS NULL) OR (maker ~ '--|^不明|-,|。|メーカー不明|？|ー'::text)) THEN ''::text\n    WHEN (maker ~ '｜'::text) THEN \"substring\"(maker, '｜(.*?)$'::text)\n    WHEN (maker ~ '[\\/\\,\\(／（\\|、]'::text) THEN \"substring\"(maker, '^(.*?)[\\/\\,\\(／（\\|、]'::text)\n    ELSE maker\nEND, '(合同|有限|株式)会社'::text, ''::text, 'g'::text))", stored: true
    t.string "top_image"
    t.index ["company_id"], name: "machines_ix4"
    t.index ["created_at"], name: "machines_ix5"
    t.index ["deleted_at"], name: "machines_ix1"
    t.index ["genre_id"], name: "machines_ix2"
    t.index ["maker"], name: "machines_ix3"
  end

  create_table "mailmagazine_log_user", id: { type: :serial, comment: "リレーションID" }, comment: "メルマガ送信ログ、ユーザリレーション", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.integer "mailmagazine_log_id", null: false, comment: "メルマガ送信ログID"
    t.index ["mailmagazine_log_id"], name: "mailmagazine_log_user_ix2"
    t.index ["user_id", "mailmagazine_log_id"], name: "mailmagazine_log_user_ix3", unique: true
    t.index ["user_id"], name: "mailmagazine_log_user_ix1"
  end

  create_table "mailmagazine_logs", id: { type: :serial, comment: "メルマガID" }, comment: "メルマガ送信ログ", force: :cascade do |t|
    t.text "contents", comment: "内容HTML"
    t.datetime "created_at", precision: nil, comment: "送信日時"
  end

  create_table "mailmagazine_machines", id: { type: :serial, comment: "メルマガID" }, comment: "新着メルマガ", force: :cascade do |t|
    t.integer "large_genre_id", null: false, comment: "大ジャンルID"
    t.integer "user_id", null: false, comment: "ユーザID"
    t.datetime "created_ata", precision: nil, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.index ["large_genre_id"], name: "mailmagazine_machines_ix1"
  end

  create_table "mails", id: { type: :serial, comment: "メールID" }, comment: "一括送信メール", force: :cascade do |t|
    t.text "subject", comment: "タイトル"
    t.text "message", comment: "内容"
    t.text "file", comment: "添付ファイル名"
    t.text "val", comment: "検索値"
    t.integer "send_count", comment: "送信数"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.text "target", comment: "送信対象"
    t.text "val_label", comment: "検索値ラベル"
    t.index ["val"], name: "mails_ix1"
  end

  create_table "mailusers", id: { type: :serial, comment: "メールユーザID" }, comment: "メールユーザ", force: :cascade do |t|
    t.text "mail", comment: "メールアドレス"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.index ["created_at"], name: "mailusers_ix1"
  end

  create_table "makers", id: { type: :serial, comment: "メーカーID" }, comment: "メーカーマスタ", force: :cascade do |t|
    t.string "maker", limit: 200, comment: "メーカー名"
    t.string "maker_kana", limit: 200, comment: "メーカー名(カナ)"
    t.string "maker_master", limit: 200, comment: "メーカーマスタ"
    t.index ["maker"], name: "makers_ix1"
    t.index ["maker_kana"], name: "makers_ix3"
    t.index ["maker_master"], name: "makers_ix2"
  end

  create_table "makers_old", id: { type: :integer, default: -> { "nextval('e2_makers_id_seq'::regclass)" }, comment: "メーカーID" }, comment: "メーカーマスタ", force: :cascade do |t|
    t.text "maker", comment: "メーカー名"
    t.text "maker_kana", comment: "メーカー名（カナ）"
    t.integer "order_no", comment: "並び順"
  end

  create_table "miniblogs", id: { type: :integer, default: -> { "nextval('miniblog_id_seq'::regclass)" }, comment: "ID" }, comment: "ミニブログ", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.text "target", comment: "対象"
    t.text "contents", comment: "内容"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
  end

  create_table "my_bid_bids", id: :serial, force: :cascade do |t|
    t.integer "bid_machine_id", null: false
    t.integer "my_user_id", null: false
    t.integer "amount", null: false
    t.text "comment", default: ""
    t.integer "sameno", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.index ["bid_machine_id"], name: "my_bid_bids_bid_machine_id_idx"
    t.index ["my_user_id"], name: "my_bid_bids_my_user_id_idx"
  end

  create_table "my_bid_trades", id: :serial, force: :cascade do |t|
    t.integer "bid_machine_id", null: false
    t.integer "my_user_id", null: false
    t.text "comment", default: "", null: false
    t.boolean "answer_flag", default: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.index ["bid_machine_id"], name: "my_bid_trades_bid_machine_id_idx"
    t.index ["my_user_id"], name: "my_bid_trades_my_user_id_idx"
  end

  create_table "my_bid_watches", id: :serial, force: :cascade do |t|
    t.integer "bid_machine_id", null: false
    t.integer "my_user_id", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.index ["bid_machine_id"], name: "my_bid_watches_bid_machine_id_idx"
    t.index ["my_user_id"], name: "my_bid_watches_my_user_id_idx"
  end

  create_table "my_users", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.text "company"
    t.text "mail", null: false
    t.text "passwd", null: false
    t.text "uniq_account"
    t.text "tel", null: false
    t.text "fax"
    t.text "zip", null: false
    t.text "addr_1", null: false
    t.text "addr_2", null: false
    t.text "addr_3", null: false
    t.boolean "mailuser_flag", default: true
    t.text "check_token"
    t.datetime "checkd_at", precision: nil
    t.datetime "freezed_at", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "passwd_changed_at", precision: nil
    t.index ["mail", "passwd"], name: "my_users_mail_passwd_idx"
  end

  create_table "mylist_companies", id: { type: :serial, comment: "マイリストID" }, comment: "マイリスト(会社）", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.integer "company_id", null: false, comment: "会社ID"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.index ["user_id"], name: "mylist_companies_ix1"
  end

  create_table "mylist_eipses", id: { type: :serial, comment: "マイリストID" }, comment: "マイリスト(EIPS）", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.integer "eips_id", null: false, comment: "EIPS ID"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.index ["user_id"], name: "mylist_eipses_ix1"
  end

  create_table "mylist_genres", id: { type: :serial, comment: "マイリストID" }, comment: "マイリスト（検索条件）", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.text "genre_ids", comment: "ジャンルID群(JSON)\t JSON"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.index ["user_id"], name: "mylist_genres_ix1"
  end

  create_table "mylist_machines", id: { type: :serial, comment: "マイリストID" }, comment: "マイリスト(機械）", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.integer "machine_id", null: false, comment: "機械ID"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.index ["user_id"], name: "mylist_machines_ix1"
  end

  create_table "mylists", id: { type: :serial, comment: "マイリストID" }, comment: "マイリスト", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザID"
    t.text "target", comment: "対象"
    t.text "query", null: false, comment: "クエリ"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.index ["user_id"], name: "mylists_ix1"
  end

  create_table "preusers", primary_key: "preuser_id", id: { type: :serial, comment: "仮ユーザID" }, comment: "仮登録ユーザ", force: :cascade do |t|
    t.text "mail", comment: "メールアドレス"
    t.text "user_name", comment: "ユーザ名"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.index ["mail"], name: "preusers_ix1"
  end

  create_table "regions", id: { type: :serial, comment: "地域ID" }, comment: "地域マスタ", force: :cascade do |t|
    t.string "region", limit: 200, comment: "地域名"
    t.decimal "lat", precision: 10, scale: 7, comment: "緯度"
    t.decimal "lng", precision: 10, scale: 7, comment: "経度"
    t.integer "order_no", comment: "並び順"
  end

  create_table "seri_bids", id: :serial, force: :cascade do |t|
    t.integer "bid_machine_id"
    t.integer "company_id"
    t.integer "amount"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil, default: -> { "now()" }
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sites", id: { type: :serial, comment: "サイトID" }, comment: "クロール対象サイトマスタ", force: :cascade do |t|
    t.text "site", null: false, comment: "サイト名"
    t.text "site_url", null: false, comment: "サイトURL"
    t.text "root_url", null: false, comment: "クロールルートURL"
    t.text "base_url", null: false, comment: "相対ベースURL"
    t.text "crawl_allow", comment: "クロール許可ワード"
    t.text "crawl_deny", comment: "クロール拒否ワード"
    t.text "crawl_code", comment: "クロール処理コード"
    t.integer "order_no", comment: "並び順"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日"
    t.datetime "changed_at", precision: nil, comment: "変更日"
    t.datetime "deleted_at", precision: nil, comment: "削除日"
  end

  create_table "states", id: { type: :serial, comment: "都道府県ID" }, comment: "都道府県マスタ", force: :cascade do |t|
    t.integer "region_id", comment: "地域ID"
    t.string "state", limit: 200, comment: "都道府県"
    t.decimal "lat", precision: 10, scale: 7, comment: "緯度"
    t.decimal "lng", precision: 10, scale: 7, comment: "経度"
    t.integer "order_no", comment: "並び順"
    t.index ["region_id"], name: "states_ix2"
    t.index ["state"], name: "states_ix1"
  end

  create_table "tracking_bid_results", id: :serial, force: :cascade do |t|
    t.text "target"
    t.integer "target_id"
    t.integer "bid_open_id"
    t.text "bid_machine_ids"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
  end

  create_table "tracking_logs", id: :serial, force: :cascade do |t|
    t.integer "tracking_user_id"
    t.text "url"
    t.integer "bid_open_id"
    t.text "bid_machine_ids"
    t.integer "contact_id"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
  end

  create_table "tracking_users", id: :serial, force: :cascade do |t|
    t.text "tracking_tag"
    t.text "ip"
    t.text "hostname"
    t.text "referer"
    t.text "addr1"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
  end

  create_table "urikai_images", force: :cascade do |t|
    t.bigint "urikai_id", null: false
    t.text "image", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_urikai_images_on_deleted_at"
    t.index ["urikai_id"], name: "index_urikai_images_on_urikai_id"
  end

  create_table "urikais", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.text "goal"
    t.text "contents"
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.text "imgs"
    t.text "tel"
    t.text "fax"
    t.text "mail"
  end

  create_table "users", id: { type: :serial, comment: "ユーザID" }, comment: "ユーザ", force: :cascade do |t|
    t.integer "company_id", comment: "会社ID"
    t.text "user_name", comment: "ユーザ名"
    t.text "mail", comment: "メールアドレス"
    t.text "passwd", comment: "パスワード（MD5）"
    t.text "tel", comment: "TEL"
    t.text "fax", comment: "FAX"
    t.text "role", comment: "権限"
    t.datetime "created_at", precision: nil, default: -> { "now()" }, comment: "登録日時"
    t.datetime "changed_at", precision: nil, comment: "変更日時"
    t.datetime "deleted_at", precision: nil, comment: "削除日時"
    t.text "account"
    t.datetime "passwd_changed_at", precision: nil
  end

  create_table "xl_genres", id: { type: :serial, comment: "特大ジャンルID" }, comment: "特大ジャンルマスタ", force: :cascade do |t|
    t.text "xl_genre", comment: "特大ジャンル名"
    t.text "xl_genre_kana", comment: "特大ジャンル名（カナ）"
    t.integer "order_no", comment: "並び順"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "changed_at", precision: nil
    t.datetime "deleted_at", precision: nil
  end

  add_foreign_key "eipses", "sites", name: "eipses_fk1"
  add_foreign_key "genre_hints", "sites", name: "genre_hints_fk2"
  add_foreign_key "large_genre_maker", "makers_old", column: "maker_id", name: "large_genre_maker_fk1"
  add_foreign_key "mailmagazine_log_user", "mailmagazine_logs", name: "mailmagazine_log_user_fk1"
  add_foreign_key "mailmagazine_log_user", "users", name: "mailmagazine_log_user_fk2"
  add_foreign_key "mailmagazine_machines", "large_genre_maker", column: "large_genre_id", name: "mailmagazine_machines_fk1"
  add_foreign_key "mailmagazine_machines", "users", name: "mailmagazine_machines_fk2"
  add_foreign_key "mylist_companies", "users", name: "mylist_companies_fk2"
  add_foreign_key "mylist_eipses", "eipses", column: "eips_id", name: "mylist_eipses_fk2"
  add_foreign_key "mylist_eipses", "users", name: "mylist_eipses_fk1"
  add_foreign_key "mylist_genres", "users", name: "mylist_genres_fk1"
  add_foreign_key "mylist_machines", "users", name: "mylist_machines_fk2"
end
