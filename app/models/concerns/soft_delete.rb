module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }
  end

  def soft_delete
    update(deleted_at: Time.current)
  end

  class_methods do
    def soft_delete_all
      update_all(deleted_at: Time.current)
    end
  end
end
