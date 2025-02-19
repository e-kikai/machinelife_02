class AlterMaiSearchLogFilters < ActiveRecord::Migration[7.1]
  def change
    add_column :mai_search_logs, :filters, :string, default: "", null: false

    add_index :mai_search_logs, :message
  end
end
