class System::DetailLogsController < ApplicationController
  def index
    ### 検索・フィルタリング処理 ###
    @detail_logs = DetailLog.includes({ machine: [:company] }, :user, :company).order(id: :desc)
      .then { |ds| params[:start_date].present? ? ds.where(created_at: params[:start_date]..) : ds }
      .then { |ds| params[:end_date].present?   ? ds.where(created_at: ..params[:end_date]) : ds }

    ### ページャ ###
    @pagy, @pdetail_logs = pagy(@detail_logs, items: 100)
  end
end
