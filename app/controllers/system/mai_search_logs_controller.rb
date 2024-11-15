class System::MaiSearchLogsController <System::ApplicationController
  def index
    ### 検索・フィルタリング処理 ###
    @mai_search_logs = MaiSearchLog.ignore_hosts.includes(:user, :company).order(id: :desc)
      .then { |cs| params[:start_date].present? ? cs.where(created_at: params[:start_date]..) : cs }
      .then { |cs| params[:end_date].present?   ? cs.where(created_at: ..params[:end_date]) : cs }
      .then { |cs| params[:user_id].present?    ? cs.where(user_id: params[:user_id]) : cs }
      .then { |cs| params[:k].present?          ? cs.where_keyword(params[:k]) : cs }

    ### ページャ ###
    @pagy, @pmai_search_logs = pagy(@mai_search_logs, items: 100)
  end
end
