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
class State < ApplicationRecord
  CONTACT_STATES_ADD = %w|海外|

  def self.count_machine
    where(open_id: @open_id).joins(:genre).group("genres.large_genre_id")
  end

  def self.selector_states
    State.order(:order_no).pluck(:state).concat(CONTACT_STATES_ADD)
  end
end
