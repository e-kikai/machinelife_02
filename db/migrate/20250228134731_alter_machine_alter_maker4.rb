class AlterMachineAlterMaker4 < ActiveRecord::Migration[7.1]
  def change
    regex = '[\/\,\(／（\|、｜]'
    maker_sql = <<"EOS"
trim(
  regexp_replace(
    regexp_replace(CASE
      WHEN maker = '-' OR maker IS NULL OR maker ~ '--|^不明|-,|。|メーカー不明|？|^[-－ー]' THEN ''
      WHEN maker ~ '[\(（].*[\)）]' THEN regexp_replace(maker, '[\(（].*[\)）]', '')
      WHEN maker ~ '[A-Za-z0-9]\s?#{regex}+.*\,?' THEN substring(maker, '[A-Za-z0-9]\s?#{regex}+(.*?)\,?$')
      WHEN maker ~ '#{regex}' THEN substring(maker, '^(.*?)#{regex}')
      ELSE maker
      END, '((合同|有限|株式)会社)|(((鉄|鐵)工|工(作|業)|(製|制)作)所?製?)', '', 'g'
    ), '([ァ-ヴ])[-－]', '\\1ー', 'g'
  )
)
EOS

    remove_column :machines, :maker2, :string
    add_column    :machines, :maker2, :virtual, type: :string, as: maker_sql, stored: true

    add_index :machines, :maker2
  end
end
