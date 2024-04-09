class AlterCompaniesAddTopImage < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :top_image, :string
    add_column :machines, :top_image, :string
  end
end
