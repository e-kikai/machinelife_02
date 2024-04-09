# == Schema Information
#
# Table name: makers
#
#  id(メーカーID)               :integer          not null, primary key
#  maker(メーカー名)            :string(200)
#  maker_kana(メーカー名(カナ)) :string(200)
#  maker_master(メーカーマスタ) :string(200)
#
# Indexes
#
#  makers_ix1  (maker)
#  makers_ix2  (maker_master)
#  makers_ix3  (maker_kana)
#
class Maker < ApplicationRecord
end
