class System::CatalogLogsController < System::ApplicationController
  def index
    ### 検索・フィルタリング処理 ###
    @catalog_logs = CatalogLog.ignore_hosts.includes({ catalog: [:genres] }, :user, :company).order(id: :desc)
      .then { |cs| params[:start_date].present? ? cs.where(created_at: params[:start_date]..) : cs }
      .then { |cs| params[:end_date].present?   ? cs.where(created_at: ..params[:end_date]) : cs }
      .then { |cs| params[:user_id].present?    ? cs.where(user_id: params[:user_id]) : cs }
      .then { |cs| params[:k].present?          ? cs.where_keyword(params[:k]) : cs }

    ### ページャ ###
    @pagy, @pcatalog_logs = pagy(@catalog_logs, items: 100)
  end
end
