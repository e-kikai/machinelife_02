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

  def total
    today = Time.zone.today

    if params[:all].present?
      @rows = (Date.new(2013, 4, 1)..today).select { |date| date.day == 1 }.map { |d| d.strftime('%Y/%m') }.reverse
      @contacts = Contact.group("to_char(created_at, 'YYYY/MM')")
      @detail_logs = DetailLog.ignore_hosts.group("to_char(created_at, 'YYYY/MM')")
      @catalog_logs = CatalogLog.ignore_hosts.group("to_char(created_at, 'YYYY/MM')")
      @search_logs = SearchLog.ignore_hosts.group("to_char(created_at, 'YYYY/MM')")

      @machines_create_count = Machine.with_deleted.group("to_char(created_at, 'YYYY/MM')").count
      @machines_delete_count = Machine.with_deleted.group("to_char(deleted_at, 'YYYY/MM')").count
    else
      @month = params[:month] ? params[:month].to_date : today

      @contacts = Contact.group("DATE(contacts.created_at)").where(created_at: @month.in_time_zone.all_month)
      @detail_logs = DetailLog.ignore_hosts.group("DATE(detail_logs.created_at)").where(created_at: @month.in_time_zone.all_month)
      @catalog_logs = CatalogLog.ignore_hosts.group("DATE(catalog_logs.created_at)").where(created_at: @month.in_time_zone.all_month)
      @search_logs = SearchLog.ignore_hosts.group("DATE(search_logs.created_at)").where(created_at: @month.in_time_zone.all_month)

      @machines_create_count = Machine.with_deleted.group("DATE(machines.created_at)").where(created_at: @month.in_time_zone.all_month).count
      @machines_delete_count = Machine.with_deleted.group("DATE(machines.deleted_at)").where(deleted_at: @month.in_time_zone.all_month).count

      @rows = @month.all_month.to_a
    end

    @contacts_system_count  = @contacts.where(machine_id: nil, company_id: nil).count
    @contacts_company_count = @contacts.where(machine_id: nil).where.not(company_id: nil).count
    @contacts_machine_count = @contacts.where.not(machine_id: nil).where.not(company_id: nil).count
    @contacts_sum_count     = @contacts.count

    @detail_logs_count = @detail_logs.count
    @detail_logs_utag_count = @detail_logs.distinct.count(:utag)

    @catalog_logs_count = @catalog_logs.count
    @catalog_logs_utag_count = @catalog_logs.distinct.count(:utag)

    @search_logs_count = @search_logs.count
    @search_logs_utag_count = @search_logs.distinct.count(:utag)

  end

  def formula
    @month = params[:month] ? params[:month].to_date : Time.zone.today
    @days = @month.end_of_month.day.to_f

    @month_select = (Date.new(2013, 4, 1)..Time.zone.today).select { |date| date.day == 1 }.map { |d| d.strftime('%Y/%-m') }.reverse

    # 機械(全体)
    @machines = Machine.with_deleted
    @machine_now = @machines.where(created_at: ..@month.end_of_month.end_of_day)
      .merge(@machines.where(deleted_at: @month.beginning_of_month.beginning_of_day..).or(@machines.where(deleted_at: nil)))

    @machine_count = @machine_now.count
    @machine_company_count = @machine_now.distinct.count(:company_id)

    # 機械登録
    @machine_create = @machines.where(created_at: @month.in_time_zone.all_month)
    @machine_create_count = @machine_create.count
    @machine_create_company_count = @machine_create.distinct.count(:company_id)
    @machine_create_genre_ranking = @machine_create
      .joins(:genre, :large_genre, :xl_genre).group("genres.genre", "large_genres.large_genre", "xl_genres.xl_genre")
      .order('count(genre_id) desc').limit(5).count

    # 機械削除
    @machine_delete = @machines.where(deleted_at: @month.in_time_zone.all_month)
    @machine_delete_count = @machine_delete.count
    @machine_delete_company_count = @machine_delete.distinct.count(:company_id)
    @machine_delete_genre_ranking = @machine_delete
      .joins(:genre, :large_genre, :xl_genre).group("genres.genre", "large_genres.large_genre", "xl_genres.xl_genre")
      .order('count(genre_id) desc').limit(5).count

    # 問い合わせ
    @contacts = Contact.where(created_at: @month.in_time_zone.all_month)
    @contact_count = @contacts.count
    @contact_mail_count = @contacts.distinct.count(:mail)
    @contact_year_count = Contact.where(created_at: @month.in_time_zone.all_year).count

    @contact_machine = @contacts.where.not(machine_id: nil).where.not(company_id: nil)
    @contact_machine_count = @contact_machine.count
    @contact_machine_ranking = @contact_machine
      .joins(:machine).group("machines.maker", "machines.name", "machines.model")
      .order('count(machine_id) desc').limit(5).count

    @contact_company_count = @contacts.where(machine_id: nil).where.not(company_id: nil).count
    @contact_system_count = @contacts.where(machine_id: nil, company_id: nil).count
    @contact_addr1_ranking = @contacts.group(:addr1).order('count(addr1) desc').limit(5).count
  end
end
