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
FactoryBot.define do
  factory :urikai do
    
  end
end
