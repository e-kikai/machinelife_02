# == Schema Information
#
# Table name: machine_nitamonos
#
#  id                :bigint           not null, primary key
#  norm              :float            not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  machine_id        :integer          not null
#  nitamono_id       :integer          not null
#
# Indexes
#
#  index_machine_nitamonos_on_machine_id                  (machine_id)
#  index_machine_nitamonos_on_machine_id_and_nitamono_id  (machine_id,nitamono_id) UNIQUE
#  index_machine_nitamonos_on_nitamono_id                 (nitamono_id)
#  index_machine_nitamonos_on_soft_destroyed_at           (soft_destroyed_at)
#
class MachineNitamono < ApplicationRecord
  belongs_to :machine
  belongs_to :nitamono, class_name: "Machine", foreign_key: "nitamono_id"
end
