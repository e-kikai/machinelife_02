header = %w[
  会社ID 会社名 会社名(カナ) 代表者 郵便番号 住所(都道府県) 住所(市区町村) 住所(番地その他)
  代表メールアドレス 代表TEL 代表FAX ウェブサイトURL
  所属団体1 所属団体2 ランク 親会社ID 親会社名
  担当者 お問い合わせメールアドレス お問い合わせTEL お問い合わせFAX 在庫件数 登録日時 変更日時
]

columns = %w[
  id company company_kana representative zip addr1 addr2 addr3
  mail tel fax website
  parents_companies.groupname groups.groupname rank parent_company_id parent_companies_companies.company
  officer contact_mail contact_tel contact_fax 0 created_at changed_at
]

CSV.generate do |row|
  row << header

  @companies.pluck(columns).each do |us|
    us[21] = @counts_by_company[us[0]]

    row << us
  end
end
