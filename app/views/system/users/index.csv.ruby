columns = %w[id user_name company_id companies.company role account passwd created_at changed_at passwd_changed_at]

CSV.generate do |row|
  row << %w[ユーザID ユーザ名 会社ID 会社名 権限 アカウント パスワード 登録日 変更日 パスワード変更日]

  @users.reorder(:id).in_batches(of: 2000) do |uss|
    uss.pluck(columns).each do |us|
      row << us
    end
  end
end
