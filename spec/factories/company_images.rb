# == Schema Information
#
# Table name: company_images
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  image      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint           not null
#
# Indexes
#
#  index_company_images_on_company_id  (company_id)
#  index_company_images_on_deleted_at  (deleted_at)
#
FactoryBot.define do
  factory :company_image do
    
  end
end
