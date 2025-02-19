class AlterMachineAlterMaker2 < ActiveRecord::Migration[7.1]
  def change
    maker_sql = <<'EOS'
trim(regexp_replace(CASE
  WHEN maker = '-' OR maker IS NULL OR maker ~ '--|^不明|-,|。|メーカー不明|？|^ー' THEN ''
  WHEN maker ~ '｜' THEN substring(maker, '｜(.*?)$')
  WHEN maker ~ '[\/\,\(／（\|、]' THEN substring(maker, '^(.*?)[\/\,\(／（\|、]')
  ELSE maker
END, '(合同|有限|株式)会社', '', 'g'))
EOS

    change_column :machines, :maker2, :virtual, type: :string, as: maker_sql, stored: true
  end
end
