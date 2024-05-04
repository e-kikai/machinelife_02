class CompaniesController < ApplicationController
  def index
    # @companies = Company.includes(:group, :parent).order(:company_kana)
    @companies = Company.includes(:group, :parent).order('company_kana COLLATE "C"')

    @counts_by_company = Machine.sales.group(:company_id).count
  end

  def show
    @company = Company.find(params[:id])
  end
end
