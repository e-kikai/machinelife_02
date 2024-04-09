class CreateUrikaiImages < ActiveRecord::Migration[7.1]
  def change
    create_table :urikai_images do |t|
      t.belongs_to :urikai, null: false
      t.text       :image,  null: false
      t.datetime   :deleted_at, index: true

      t.timestamps
    end
  end
end
