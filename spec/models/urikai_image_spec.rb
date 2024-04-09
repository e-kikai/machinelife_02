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
require 'rails_helper'

RSpec.describe UrikaiImage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
