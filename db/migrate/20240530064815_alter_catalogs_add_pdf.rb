class AlterCatalogsAddPdf < ActiveRecord::Migration[7.1]
  def change
    add_column :catalogs, :pdf, :string
  end
end
