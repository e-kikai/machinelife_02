class Zenkiren::CompaniesController < ApplicationController
  layout 'zenkiren/layouts/application'

  def tokyo
    get_groups(1)
  end

  def osaka
    get_groups(3)
  end

  def chubu
    get_groups(2)
  end

  private

  def get_groups(parent_id)
    @groups = Group.includes(:companies, :parent).where(parent_id:, companies: { deleted_at: nil })
      .order(:parent_id, :id, 'company_kana COLLATE "C"', "companies.id")
  end
end
