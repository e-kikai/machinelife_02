# == Schema Information
#
# Table name: urikai_images
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  image      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  urikai_id  :bigint           not null
#
# Indexes
#
#  index_urikai_images_on_deleted_at  (deleted_at)
#  index_urikai_images_on_urikai_id   (urikai_id)
#
class UrikaiImage < ApplicationRecord
  include SoftDelete

  belongs_to :urikai

  mount_uploader :image, CompanyImageUploader
end
