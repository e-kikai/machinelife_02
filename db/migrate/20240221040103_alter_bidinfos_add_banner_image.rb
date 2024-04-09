class AlterBidinfosAddBannerImage < ActiveRecord::Migration[7.1]
  def change
    add_column :bidinfos, :banner_image, :string
  end
end
