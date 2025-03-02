class System::SearchLogsController < System::ApplicationController
  def index
    ### 検索・フィルタリング処理 ###
    # @search_logs = SearchLog.ignore_hosts.includes(:user, :company).order(id: :desc)
    @search_logs = SearchLog.includes(:user, :company).order(id: :desc)
      .then { |cs| params[:start_date].present? ? cs.where(created_at: params[:start_date]..) : cs }
      .then { |cs| params[:end_date].present?   ? cs.where(created_at: ..params[:end_date]) : cs }
      .then { |cs| params[:user_id].present?    ? cs.where(user_id: params[:user_id]) : cs }
      .then { |cs| params[:k].present?          ? cs.where_keyword(params[:k]) : cs }

    ### ページャ ###
    @pagy, @psearch_logs = pagy(@search_logs, limit: 100)
  end
end
