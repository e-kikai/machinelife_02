class HelpsController < ApplicationController
  PAGES = {
    banner: "広告バナー掲載のご案内 ",
    rank: "会員区分と利用サービスについて"
  }.freeze

  def index; end

  def show
    @key   = params[:id].to_sym
    @title = PAGES[@key]

    redirect :index if @title.blank?
  end

  def sitemap
    machines = Machine.sales
    # @makers = Machine.left_joins(maker_m: [:maker_k]).where.not(maker2: ["", "xxx", nil])
    #   .group("COALESCE(makers.maker_master, machines.maker2)", "COALESCE(maker_ks_makers.maker_kana, machines.maker2)")
    #   .order(Arel.sql("COALESCE(maker_ks_makers.maker_kana, machines.maker2)")).count
    #   # .to_h { |k, v| [k[0], v] }

    @makers =
      machines
        .left_joins(:maker_m)
        .where.not(maker2: ["", "xxx", nil])
        .group("COALESCE(makers.maker_master, machines.maker2)", "COALESCE(makers.maker_kana, machines.maker2)")
        .count
        .sort_by { |k, _| [(k[1].match?(/^[0-9A-Za-z]/) ? 1 : 0), k[1].to_s] }.to_h { |k, v| [k[0], v] }

    @xl_genres             = XlGenre.order(:order_no).includes(:large_genres, :genres)
    @counts_by_xl_genre    = machines.joins(:xl_genre).group("xl_genres.id").count
    @counts_by_large_genre = machines.joins(:large_genre).group("large_genres.id").count
    @counts_by_genre       = machines.joins(:genre).group("genre_id").count

    @companies         = Company.includes(:group, :parent).order(:company_kana)
    @counts_by_company = machines.group(:company_id).count

    @counts_by_state = machines.group("addr1").count
  end
end
