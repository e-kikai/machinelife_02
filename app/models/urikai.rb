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
class Urikai < ApplicationRecord
  include SoftDelete

  belongs_to :company
  has_many :urikai_images

  MEDIA_URL = "https://s3-ap-northeast-1.amazonaws.com/machinelife/machine/public/media/machine/".freeze

  ### value ###
  composed_of :imgs_parsed, class_name: "JsonToMedias", mapping: [%i[imgs json]], constructor: ->(imgs) { JsonToMedias.new(imgs, MEDIA_URL) }

  GOALS_JP = {
    cell: ["売りたし", "text-danger"],
    buy: ["買いたし", "text-primary"]
  }.freeze

  def goal_jp
    GOALS_JP.dig(goal.to_sym, 0)
  end

  def goal_class
    GOALS_JP.dig(goal.to_sym, 1)
  end
end
