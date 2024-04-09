# == Schema Information
#
# Table name: machine_images
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  image      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  machine_id :bigint           not null
#
# Indexes
#
#  index_machine_images_on_deleted_at  (deleted_at)
#  index_machine_images_on_machine_id  (machine_id)
#
FactoryBot.define do
  factory :machine_image do
    
  end
end
