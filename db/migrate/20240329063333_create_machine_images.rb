class CreateMachineImages < ActiveRecord::Migration[7.1]
  def change
    create_table :machine_images do |t|
      t.belongs_to :machine, null: false
      t.text       :image,   null: false
      t.datetime   :deleted_at, index: true

      t.timestamps
    end
  end
end
