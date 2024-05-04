class Daihou::ApplicationController < ApplicationController
  before_action :set_company
  before_action :set_contact_visibility

  layout 'daihou/layouts/application'

  def set_company
    @company = Company.find(DInfo::DAIHOU_COMPANY_ID)
  end

  def set_contact_visibility
    @show_contact = true
  end
end
