class HelpsController < ApplicationController
  def index
  end

  def show
  end

  def sitemap
    machines = Machine.sales
    @makers = machines.where.not(maker2: "")
      .group("COALESCE(makers.maker_master, machines.maker2)").count

    @xl_genres             = XlGenre.order(:order_no).includes(:large_genres)
    @counts_by_xl_genre    = machines.joins(:xl_genre).group("xl_genres.id").count
    @counts_by_large_genre = machines.joins(:large_genre).group("large_genres.id").count
    # @counts_by_genre       = machines.group("genre_id").count
  end
end
