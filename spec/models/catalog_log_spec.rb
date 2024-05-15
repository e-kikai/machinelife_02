# == Schema Information
#
# Table name: catalog_logs
#
#  id         :bigint           not null, primary key
#  host       :string           default("")
#  ip         :string           default("")
#  r          :string           default(""), not null
#  referer    :string           default("")
#  ua         :string           default("")
#  utag       :string           default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  catalog_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_catalog_logs_on_catalog_id  (catalog_id)
#  index_catalog_logs_on_user_id     (user_id)
#
require 'rails_helper'

RSpec.describe CatalogLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
