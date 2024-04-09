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
end
