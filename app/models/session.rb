class Session < ApplicationRecord
  ### 古いセッションデータをクリア ###
  def self.sweep(old = 1.month)
    where("updated_at < '#{old.ago}'").delete_all
  end
end
