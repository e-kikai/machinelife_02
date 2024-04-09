# == Schema Information
#
# Table name: machine_pdfs
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string           not null
#  pdf        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  machine_id :bigint           not null
#
# Indexes
#
#  index_machine_pdfs_on_deleted_at  (deleted_at)
#  index_machine_pdfs_on_machine_id  (machine_id)
#
require 'rails_helper'

RSpec.describe MachinePdf, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
