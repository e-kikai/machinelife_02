class MainController < ApplicationController
  def index
    machines         = Machine.sales
    @machines_count  = machines.count
    @companies_count = machines.distinct(:company_id).count("distinct company_id")

    @news = machines.only_machines.news

    @xl_genres             = XlGenre.order(:order_no).includes(:large_genres)
    @counts_by_xl_genre    = machines.joins(:xl_genre).group("xl_genres.id").count
    @counts_by_large_genre = machines.joins(:large_genre).group("large_genres.id").count

    @bidinfos = Bidinfo.where(bid_date: Time.current..).where.not(banner_image: nil).order(:bid_date)

    @states          = State.order(:order_no)
    @counts_by_state = machines.group("addr1").count

    @header_full = true
  end

  def test
    machines         = Machine.sales
    @machines_count  = machines.count
    @companies_count = machines.distinct(:company_id).count("distinct company_id")

    @news = machines.only_machines.news

    @xl_genres             = XlGenre.order(:order_no).includes(:large_genres)
    @counts_by_xl_genre    = machines.joins(:xl_genre).group("xl_genres.id").count
    @counts_by_large_genre = machines.joins(:large_genre).group("large_genres.id").count

    @bidinfos = Bidinfo.where(bid_date: Time.current..).where.not(banner_image: nil).order(:bid_date)

    @states          = State.order(:order_no)
    @counts_by_state = machines.group("addr1").count

    @header_full = true
  end

  def feed
    # 新着
    case params[:mail]
    when "2"
      # 新着メール用 (会員用、日毎)
      @date = Time.current.yesterday
      @machine_count = Machine.sales.where(created_at: @date.all_day).count
      @genres = Genre.includes(machines: [:company]).where(machines: { deleted_at: nil, created_at: @date.all_day }).order(:order_no)

      @bidinfos = Bidinfo.where(bid_date: Time.current..).order(:bid_date)

      rend = :admin_mail_feed
    when "1"
      # 新着メール用 (ユーザ用、 週ごと)
      @date = Time.current.ago(1.week).end_of_week
      @machines = Machine.sales.where(created_at: @date.all_week).where.not(top_image: nil).reorder("RANDOM()").limit(12)
      @r = :cmp_cnu
      rend = :feed
    else
      @date = Time.current
      @machines = Machine.sales.where(created_at: Machine::NEWS_DAY..).order(created_at: :desc).limit(300)
      @r = :rss
      rend = :feed
    end
    # @machines =
    #   if params[:mail]
    #     # 新着メール用
    #     # Machine.sales.where(created_at: Machine::NEWS_MAIL_DAY..).where.not(top_image: nil).reorder("RANDOM()").limit(12)
    #     Machine.sales.where(created_at: Time.current.ago(1.week).all_week).where.not(top_image: nil).reorder("RANDOM()").limit(12)
    #   else
    #     Machine.sales.where(created_at: Machine::NEWS_DAY..).order(created_at: :desc).limit(300)
    #   end

    respond_to do |format|
      format.rss { render rend, format: :rss }
    end
  end

  # 会員向け新着メール用
  def admin_mail_feed
    @date = Time.current.yesterday
    @machine_count = Machine.sales.where(created_at: @date.all_day).count
    @genres = Genre.includes(machines: [:company]).where(machines: { deleted_at: nil, created_at: @date.all_day }).order(:order_no)

    @bidinfos = Bidinfo.where(bid_date: Time.current..).order(:bid_date)

    respond_to do |format|
      format.rss
    end
  end
end
