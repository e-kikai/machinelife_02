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

  def feed
    # 新着
    @machines =
      if params[:mail]
        # 新着メール用
        Machine.sales.where(created_at: Machine::NEWS_MAIL_DAY..).where.not(top_image: nil).reorder("RANDOM()").limit(12) if params[:mail]
      else
        Machine.sales.where(created_at: Machine::NEWS_DAY..).order(created_at: :desc).limit(300)
      end

    respond_to do |format|
      format.rss
    end
  end

  # 会員向け新着メール用
  def admin_mail_feed
    @date = Machine::NEWS_ADMIN_MAIL_DAY
    @machine_count = Machine.sales.where(created_at: @date.all_day).count
    @genres = Genre.includes(machines: [:company]).where(machines: { deleted_at: nil, created_at: @date.all_day }).order(:order_no)

    @bidinfos = Bidinfo.where(bid_date: Time.current..).order(:bid_date)

    respond_to do |format|
      format.rss
    end
  end
end
