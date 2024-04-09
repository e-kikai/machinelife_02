class CreateCompanyImages < ActiveRecord::Migration[7.1]
  def change
    create_table :company_images do |t|
      t.belongs_to :company, null: false
      t.text       :image,   null: false
      t.datetime   :deleted_at, index: true

      t.timestamps
    end
  end
end
