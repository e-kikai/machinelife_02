class Playground::OpenaiTest01Controller < ApplicationController
  include Hosts

  # before_action :check_env
  before_action :set_mai_search_log, only: [:good, :bad]
  around_action :skip_bullet

  def index; end

  def search
    redirect_to "/playground/openai_test01/", flash: { message: params[:message] }
  end

  def show
    machine = Machine.sales.find(params[:id])

    res = MaiSearch.to_mai_json_hash(machine).to_json.gsub(/(\s|\\r|\\n|　)+/, " ")

    render json: res
  end

  def create
    start_time = Time.current # 処理速度計測
    @message = params[:message]&.strip

    begin
      # 追加フィルタリング条件
      filters = params[:f].present? ? params.require(:f).permit(maker: [], addr1: [], year: [], capacity: []).to_h : {}

      if @message.present?
        @mai_search = MaiSearch.new(message: @message, filters:)
        @mai_search.call
      else
        @error_mes = "質問がありません。"
      end
    rescue StandardError => e
      # @error = e.full_message
      @error = e.message
      @error_mes = e.message if @error_mes.blank?
      raise e.message
    end

    @time = Time.current - start_time

    # if logging?
    if logging? || system_user?
      @mai_search_log = MaiSearchLog.create(
        log_data(
          {
            message: @mai_search.message || "",
            keywords: @mai_search.wheres.to_json.strip || "",
            filters: @mai_search.filters.to_json.strip || "",
            search_count: @mai_search.machines&.count || 0,
            search_level: @mai_search.level || 0,
            count: @sort_machines&.count || 0,
            report: @report_text&.strip || "",
            time: @time || 0,
            error: @error || ""
          }
        )
      )
    end
  end

  def good
    @mai_search_log.toggle(:good).update(bad: false)
  end

  def bad
    @mai_search_log.toggle(:bad).update(good: false)
  end

  def help; end

  private

  def set_mai_search_log
    @mai_search_log = MaiSearchLog.find(params[:id])
  end

  def check_env
    # redirect_to "/" if Rails.env.production?
  end

  # Bullet処理のスキップ
  def skip_bullet
    Bullet.enable = false if Rails.env.development?
    yield
  ensure
    Bullet.enable = true if Rails.env.development?
  end
end
