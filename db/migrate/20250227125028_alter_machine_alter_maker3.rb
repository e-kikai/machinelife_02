class AlterMachineAlterMaker3 < ActiveRecord::Migration[7.1]
  def change
    maker_sql = <<'EOS'
trim(
  regexp_replace(
    regexp_replace(CASE
      WHEN maker = '-' OR maker IS NULL OR maker ~ '--|^不明|-,|。|メーカー不明|？|^ー' THEN ''
      WHEN maker ~ '｜' THEN substring(maker, '｜(.*?)$')
      WHEN maker ~ '[\/\,\(／（\|、]' THEN substring(maker, '^(.*?)[\/\,\(／（\|、]')
      ELSE maker
      END, '((合同|有限|株式)会社)|(((鉄|鐵)工|工(作|業)|(製|制)作)所?)', '', 'g'
    ), '([ァ-ヴ])\-', '\1ー'
  )
)
EOS

    remove_column :machines, :maker2, :string
    add_column    :machines, :maker2, :virtual, type: :string, as: maker_sql, stored: true
  end
end
