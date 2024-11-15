class CreateMaiSearchLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :mai_search_logs do |t|
      t.belongs_to :user,    index: true

      t.string :message, default: "", null: false, comment: '質問文'
      t.string :keywords, default: "", null: false, comment: '検索キーワード'
      t.integer :search_count, default: 0, null: false, comment: '検索結果件数'
      t.integer :search_level, default: 0, null: false, comment: '検索レベル'
      t.integer :count, default: 0, null: false, comment: '最終結果件数'
      t.text :report, default: "", null: false, comment: 'レポート'
      t.float :time, default: 0, null: false, comment: '処理時間'
      t.text :error, default: "", null: false, comment: 'エラー'
      t.boolean :good, default: false, null: false, comment: '高評価'
      t.boolean :bad, default: false, null: false, comment: '低評価'

      t.string :utag,    default: ""
      t.string :ip,      default: ""
      t.string :host,    default: ""
      t.string :ua,      default: ""
      t.string :referer, default: ""
      t.string :r,       default: "", null: false

      t.timestamps
    end
  end
end
