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
class DInfo < ApplicationRecord
  include SoftDelete

  DAIHOU_COMPANY_ID = 320

  belongs_to :company
end
