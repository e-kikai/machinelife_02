class CreateDetailLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :detail_logs do |t|
      t.belongs_to :user,    index: true
      t.belongs_to :machine, index: true

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
