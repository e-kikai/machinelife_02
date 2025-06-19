class AlterMachineAlterMaker5 < ActiveRecord::Migration[7.1]
  def change
    execute <<~SQL
CREATE OR REPLACE FUNCTION normalize_maker_name(text)
RETURNS text AS $$
DECLARE
  s text;
BEGIN
  -- 0. 無効値除去
  IF $1 IS NULL OR $1 = '-' OR $1 ~ '^(--|[-－ー]|,|。|？|メーカー不明|不明|なし|様々)' THEN
    RETURN '';
  END IF;

  -- 1. 数字・記号で始まる場合は除外
  IF $1 ~ '^[0-9\W_]' THEN
    RETURN '';
  END IF;

  s := $1;

  -- 2. 全角スペース → 半角スペース
  s := TRANSLATE(s, '　|\t', ' ');

  -- 3. 丸括弧除去（安全のため再適用）
  s := REGEXP_REPLACE(s, '[\(（][^\)）]*[\)）]', '', 'g');

  -- 4. 英数区切り記号（スラッシュや括弧）以降でカット
  IF s ~ '[A-Za-z0-9]\s?[\/\,\(／（\|、｜]+.*\,?' THEN
    s := substring(s, '[A-Za-z0-9]\s?[\/\,\(／（\|、｜]+(.*?)\,?$');
  END IF;

  -- 5. 区切り記号（スラッシュや括弧）以前でカット
  IF s ~ '[\/\,\(／（\|、｜]' THEN
    s := substring(s FROM '^(.*?)[/\\,\\(／（\\|、｜]');
  END IF;

  -- 6. 法人・工場系語句の除去
  s := REGEXP_REPLACE(s, '((合同|有限|株式)会社)|(((鉄|鐵)工|工(作|業)|(製|制)作)所?製?)', '', 'g');

  -- 7. 長音記号統一
  s := REGEXP_REPLACE(s, '([ァ-ヴ])[-－]', '\\1ー', 'g');

  -- 8. ひらがな → カタカナ
  -- s := TRANSLATE(s,
  --     'ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろわをんゎゐゑ',
  --     'ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロワヲンヮヰヱ');

  -- 9. 許容記号（A-Z0-9 & - 空白）のみ残す
  -- s := REGEXP_REPLACE(s, '[^A-Z0-9ァ-ンー一-龥&\s-]', '', 'g');

  -- 10. 複数スペースを1つにまとめる
  s := REGEXP_REPLACE(s, '\s+', ' ', 'g');

  -- 11. 大文字化
  s := UPPER(s);

  -- 12. 末尾の「社製」「製」「他」「不明」などを除去
  s := REGEXP_REPLACE(s, '(社製|社|製|他|不明)$', '', 'g');

  RETURN TRIM(s);
END;
$$ LANGUAGE plpgsql IMMUTABLE;
    SQL

    remove_column :machines, :maker2, :string
    add_column    :machines, :maker2, :virtual, type: :string, as: "normalize_maker_name(maker)", stored: true

    add_index :machines, :maker2
  end
end
