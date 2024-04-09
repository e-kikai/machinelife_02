# == Schema Information
#
# Table name: urikais
#
#  id         :integer          not null, primary key
#  changed_at :datetime
#  contents   :text
#  deleted_at :datetime
#  end_date   :datetime
#  fax        :text
#  goal       :text
#  imgs       :text
#  mail       :text
#  tel        :text
#  created_at :datetime
#  company_id :integer
#
require 'rails_helper'

RSpec.describe Urikai, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
