class MachinesController < ApplicationController
  require 'nkf'
  before_action :search_filtering, only: [:index, :large_genre, :genre, :maker, :company]

  def index; end

  def large_genre
    large_genre = LargeGenre.find(params[:large_genre_id])
    @bread = [:large_genre, large_genre]
    @title = "#{large_genre.large_genre} 在庫一覧"

    render :index
  end

  def genre
    genre = Genre.find(params[:genre_id])
    @bread = [:genre, genre]
    @title = "#{genre.genre} 在庫一覧"

    render :index
  end

  def company
    company = Company.find(params[:company_id])
    @bread = [:machines_company, company]
    @title = "#{company.company} 在庫一覧"

    render :index
  end

  def maker
    @bread = [:something, params[:maker]]
    @title = "メーカー:#{params[:maker]} 検索結果"

    render :index
  end

  def show
    @machine = Machine.find(params[:id])

    @sames     = @machine.sames.sales.order(created_at: :desc)
    @nitamonos = @machine.nitamonos.sales.order("machine_nitamonos.norm").limit(15)
  end

  def news
    if params[:target] == "machines"
      @news  = Machine.sales.only_machines.order(created_at: :desc)
      @title = "新着中古機械一覧"
    else
      @news  = Machine.sales.only_tools.order(created_at: :desc)
      @title = "新着中古工具一覧"
    end

    @date =
      begin
        DateTime.parse(params[:date])
      rescue StandardError
        Time.current
      end

    created_at, @view_date =
      if params[:date] && params[:week]
        [@date.all_week, "(#{@date.beginning_of_week.strftime('%Y/%-m/%-d')} 〜 #{@date.end_of_week.strftime('%Y/%-m/%-d')})"]
      elsif params[:date]
        [@date.all_day, "(#{@date.strftime('%Y/%-m/%-d')})"]
      else
        [Machine::NEWS_DAY.., ""]
      end

    @news = @news.where(created_at: created_at)

    @pagy, @pnews = pagy(@news, items: 50)
  end

  private

  def search_filtering
    ### ナビゲーションデフォルト ###
    @bread = [:something, "検索結果"]
    @title = "検索結果"

    ### 検索・フィルタリング処理 ###
    @machines = Machine.sales
      .then { |ms| params[:large_genre_id].present? ? ms.where(genres: { large_genre_id: params[:large_genre_id] }) : ms }
      .then { |ms| params[:genre_id].present?   ? ms.where(genre_id: params[:genre_id])     : ms }
      .then { |ms| params[:company_id].present? ? ms.where(company_id: params[:company_id]) : ms }
      .then { |ms| params[:maker].present?      ? ms.where_maker(params[:maker])            : ms }
      .then { |ms| params[:makers].present?     ? ms.where_maker(params[:makers])           : ms }
      .then { |ms| params[:genre_ids].present?  ? ms.where(genre_id: params[:genre_ids])    : ms }
      .then { |ms| params[:model].present?      ? ms.where_model2(params[:model])           : ms }
      .then { |ms| params[:addr1].present?      ? ms.where(addr1: params[:addr1])           : ms }
      .then { |ms| params[:k].present?          ? ms.where_keyword(params[:k])              : ms }

    ### ソート・ページャ ###
    @pagy, @pmachines = pagy(@machines.order_by_key(params[:sort]))

    ### フィルタリング項目 ###
    @filtering_genres = @machines.group("machines.genre_id", "genres.genre").order(count: :desc, genre_id: :asc).limit(100).count
    @filtering_makers = @machines.where.not(maker2: "").group("COALESCE(makers.maker_master, machines.maker2)").order(count: :desc).limit(100).count
    @filtering_addr1s = @machines.where.not(addr1: "").group(:addr1).order(count: :desc).count.map { |k, v| ["#{k} (#{v})", k] }

    # filter check 用
    @fc_genres = @filtering_genres.map { |k, v| { target: :genre_ids, label: k[1], value: k[0], count: v, cls: "col-2" } }
    @fc_makers = @filtering_makers.map { |k, v| { target: :makers, label: k, value: k, count: v, cls: "col-2" } }
  end
end
