# == Schema Information
#
# Table name: groups
#
#  id(団体ID)           :integer          not null, primary key
#  changed_at(変更日時) :datetime
#  deleted_at(削除日時) :datetime
#  groupname(団体名)    :text
#  created_at(登録日時) :datetime
#  parent_id(親団体ID)  :integer
#
# Indexes
#
#  groups_ix1  (parent_id)
#
require "test_helper"

class GroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
