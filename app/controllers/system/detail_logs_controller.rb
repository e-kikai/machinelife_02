class System::DetailLogsController < System::ApplicationController
  def index
    ### 検索・フィルタリング処理 ###
    @detail_logs = DetailLog.ignore_hosts.includes({ machine: [:company] }, :user, :company).order(id: :desc)
      .then { |ds| params[:start_date].present? ? ds.where(created_at: params[:start_date]..) : ds }
      .then { |ds| params[:end_date].present?   ? ds.where(created_at: ..params[:end_date]) : ds }
      .then { |ds| params[:user_id].present?    ? ds.where(user_id: params[:user_id]) : ds }
      .then { |ds| params[:k].present?          ? ds.where_keyword(params[:k]) : ds }

    ### ページャ ###
    @pagy, @pdetail_logs = pagy(@detail_logs, limit: 100)
  end

  def ip_counts
    @start_date       = params[:start_date] || 1.week.ago
    @end_date         = params[:end_date]
    @detail_logs      = DetailLog.where(created_at: @start_date..@end_date)
    @hosts            = @detail_logs.distinct.pluck(:ip, :host).to_h
    @detail_log_count = @detail_logs.group(:ip).order(count: :desc).count
    @utag_count       = @detail_logs.group(:ip).distinct.count(:utag)
    @machine_id_count = @detail_logs.group(:ip).distinct.count(:machine_id)

    # ### ページャ ###
    # @pagy, @pdetail_logs = pagy(@detail_log_count, limit: 100)
  end
end
