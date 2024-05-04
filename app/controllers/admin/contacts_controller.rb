class Admin::ContactsController < Admin::ApplicationController
  def index
    @contacts = Contact.includes(:machine).where(company: current_company).order(id: :desc)

    @pagy, @pcontacts = pagy(@contacts, items: 50)
  end
end
