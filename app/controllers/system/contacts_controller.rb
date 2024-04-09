class System::ContactsController < System::ApplicationController
  def index
    @contacts = Contact.where(company_id: nil, machine_id: nil).order(id: :desc)

    @pagy, @pcontacts = pagy(@contacts, items: 50)
  end

  def all
    @contacts = Contact.includes(:company, :machine).order(id: :desc)

    if params[:year].present? && params[:month].present?
      date = "#{params[:year]}/#{params[:month]}/1"
      @contacts = @contacts.where(created_at: date.in_time_zone.all_month)
    else
      @contacts = @contacts.limit(50)
    end
  end
end
