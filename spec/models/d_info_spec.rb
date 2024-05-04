# == Schema Information
#
# Table name: d_infos
#
#  id         :integer          not null, primary key
#  changed_at :datetime
#  contents   :text
#  deleted_at :datetime
#  info_date  :date
#  title      :string(255)
#  created_at :datetime
#  company_id :integer
#
require 'rails_helper'

RSpec.describe DInfo, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
