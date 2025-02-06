class System::MaiSearchLogsController <System::ApplicationController
  def index
    ### 検索・フィルタリング処理 ###
    @mai_search_logs = MaiSearchLog.ignore_hosts.includes(:user, :company).order(id: :desc)
      .then { |cs| params[:start_date].present? ? cs.where(created_at: params[:start_date]..) : cs }
      .then { |cs| params[:end_date].present?   ? cs.where(created_at: ..params[:end_date]) : cs }
      .then { |cs| params[:user_id].present?    ? cs.where(user_id: params[:user_id]) : cs }
      .then { |cs| params[:k].present?          ? cs.where_keyword(params[:k]) : cs }
      .then { |cs| params[:filter] == "zero"    ? cs.where(search_count: 0) : cs }
      .then { |cs| params[:filter] == "over"    ? cs.where(search_count: 101..) : cs }
      .then { |cs| params[:filter] == "good"    ? cs.where(good: true) : cs }
      .then { |cs| params[:filter] == "bad"    ? cs.where(bad: true) : cs }

    ### ページャ ###
    @pagy, @pmai_search_logs = pagy(@mai_search_logs, limit: 100)
  end

  def total
    today = Time.zone.today

    if params[:all].present?
      @rows = (Date.new(2024, 11, 1)..today).select { |date| date.day == 1 }.map { |d| d.strftime('%Y/%m') }.reverse

      @mai_search_logs = MaiSearchLog.ignore_hosts.group("to_char(created_at, 'YYYY/MM')")
      @detail_logs_all = DetailLog.ignore_hosts.group("to_char(created_at, 'YYYY/MM')")
      @detail_logs     = @detail_logs_all.where("r LIKE '%mai%'")
      @contacts_all    = Contact.where.not(machine_id: nil).where.not(company_id: nil).group("to_char(created_at, 'YYYY/MM')")
    else
      @month = params[:month] ? params[:month].to_date : today
      @rows = @month.all_month.to_a

      @mai_search_logs = MaiSearchLog.ignore_hosts.group("DATE(mai_search_logs.created_at)").where(created_at: @month.in_time_zone.all_month)
      @detail_logs_all = DetailLog.ignore_hosts.group("DATE(detail_logs.created_at)").where(created_at: @month.in_time_zone.all_month)
      @detail_logs     = @detail_logs_all.where("r LIKE '%mai%'")
      @contacts_all    = Contact.where.not(machine_id: nil).where.not(company_id: nil).group("DATE(contacts.created_at)").where(created_at: @month.in_time_zone.all_month)
    end

    @mai_search_logs_count      = @mai_search_logs.count
    @mai_search_logs_utag_count = @mai_search_logs.distinct.count(:utag)
    @mai_search_logs_zero_count = @mai_search_logs.where(search_count: 0).count
    @mai_search_logs_adv_count  = @mai_search_logs.where(search_count:  1..100).count
    @mai_search_logs_over_count = @mai_search_logs.where(search_count: 101..).count

    @mai_search_logs_good_count = @mai_search_logs.where(good: true).count
    @mai_search_logs_bad_count  = @mai_search_logs.where(bad: true).count

    @contacts               = @contacts_all.where("r LIKE '%mai%'")
    @contacts_sum_count     = @contacts.count
    @contacts_all_count     = @contacts_all.count
    @contacts_utag_count    = @contacts.distinct.count(:utag)
    @contacts_adv_count     = @contacts.where("r LIKE '%adv%'").count
    @contacts_blk_count     = @contacts.where("r LIKE '%blk%'").count
    @contacts_crd_count     = @contacts.where("r LIKE '%crd%'").count

    @detail_logs_sum_count  = @detail_logs.count
    @detail_logs_all_count  = @detail_logs_all.count
    @detail_logs_utag_count = @detail_logs.distinct.count(:utag)
    @detail_logs_adv_count  = @detail_logs.where("r LIKE '%adv%'").count
    @detail_logs_crd_count  = @detail_logs.where("r LIKE '%crd%'").count
  end
end
