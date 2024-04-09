class FormBase
  include ActiveModel::Model
  include ActiveModel::Attributes

  def initialize(attributes = nil)
    attributes ||= default_attributes
    super(attributes)
  end

  def id
    nil
  end

  def persisted?
    false
  end

  def save
    attributes_format

    valid? ? persist : false
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error([e.message, *e.backtrace].join($RS))
    errors.add(:base, e.message)

    false
  end

  private

  def default_attributes
    {}
  end

  def persist
    true
  end

  def attributes_format
    true
  end
end
