class CreateSearchLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :search_logs do |t|
      t.belongs_to :user, index: true
      t.string :path,     default: ""
      t.integer :page,    default: 1
      t.integer :count,   default: 0

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
