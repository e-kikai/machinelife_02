class AlterXlGenresIcon < ActiveRecord::Migration[7.1]
  def change
    add_column :xl_genres , :icon, :string, default: ""
    add_column :large_genres , :icon, :string, default: ""
    add_column :genres , :icon, :string, default: ""
  end
end
