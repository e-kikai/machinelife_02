class CreateMachinePdfs < ActiveRecord::Migration[7.1]
  def change
    create_table :machine_pdfs do |t|
      t.belongs_to :machine, null: false
      t.string     :pdf,     null: false
      t.string     :name,    null: false

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
