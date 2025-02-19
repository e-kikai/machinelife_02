class AlterMachinesSearchKeyword < ActiveRecord::Migration[7.1]
  def change
    add_column :machines, :search_keyword,  :text, default: ""
    add_column :machines, :search_capacity, :text, default: ""

    add_index :machines, :maker2
    add_index :machines, :addr1
    add_index :machines, :year
  end
end
