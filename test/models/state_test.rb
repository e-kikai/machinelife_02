# == Schema Information
#
# Table name: states
#
#  id(都道府県ID)    :integer          not null, primary key
#  lat(緯度)         :decimal(10, 7)
#  lng(経度)         :decimal(10, 7)
#  order_no(並び順)  :integer
#  state(都道府県)   :string(200)
#  region_id(地域ID) :integer
#
# Indexes
#
#  states_ix1  (state)
#  states_ix2  (region_id)
#
require "test_helper"

class StateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
