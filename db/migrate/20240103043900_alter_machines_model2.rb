class AlterMachinesModel2 < ActiveRecord::Migration[7.1]
  def change
    msql = <<'EOS'
trim(regexp_replace(CASE
  WHEN maker = '-' OR maker IS NULL OR maker ~ '--|^不明|-,|。|メーカー不明|？|ー' THEN ''
  WHEN maker ~ '｜' THEN substring(maker, '｜(.*?)$')
  WHEN maker ~ '[\/\,\(／（\|、]' THEN substring(maker, '^(.*?)[\/\,\(／（\|、]')
  ELSE maker
END, '(合同|有限|株式)会社', '', 'g'))
EOS

    add_column(:machines, :model2, :virtual, type: :string,
      as: "regexp_replace(upper(model), '[^A-Z0-9]+', '', 'g')", stored: true)

    add_column(:machines, :maker2, :virtual, type: :string, as: msql, stored: true)
  end
end
