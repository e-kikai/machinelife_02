class Admin::CatalogsController < Admin::ApplicationController
  before_action :check_rank

  def index
    @maker_counts = Catalog.group(:maker, :maker_kana).order(:maker_kana, :maker).count
    # @infos = Info.where(target: :catalog).order(info_date: :desc).limit(10)
    @miniblogs = Miniblog.includes(:user).where(target: :catalog).order(created_at: :desc).limit(20)
    @catalog_count = Catalog.count

    @miniblog_form = Admin::MiniblogForm.new({target: :catalog})
  end

  def search
    search_filtering

    @title = "#{params[:ma]} #{params[:mo]}".strip
    @catalog_request_form = Admin::CatalogRequestForm.new
  end

  def create
    @catalog_request_form = Admin::CatalogRequestForm.new(catalog_request_params, user: current_user)

    if @catalog_request_form.save
      flash.now[:notice] = "リクエスト送信が完了しました。\n\n送信されたリクエストは、全機連事務局より、\n全機連会員に向けて調査依頼メールを配信いたします。"
    else
      flash.now[:danger] = '送信に失敗しました'
    end

    render "_form"
  end

  def manuals; end

  private

  def search_filtering
    ### 検索・フィルタリング処理 ###
    @catalogs = Catalog.joins(:catalog_genres).includes(:genres)
      .then { |cs| params[:ma].present? ? cs.where(maker: params[:ma]) : cs }
      .then { |cs| params[:mo].present? ? cs.where_keyword(params[:mo]) : cs }
      .then { |cs| params[:makers].present? ? cs.where(maker: params[:makers]) : cs }
      .then { |cs| params[:genre_ids].present? ? cs.where(catalog_genres: { genre_id: params[:genre_ids] }) : cs }
      .then { |cs| params[:model].present? ? cs.where_keyword(params[:model]) : cs }

    # ### ソート・ページャ ###
    # @pagy, @pmachines = pagy(@machines.order_by_key(params[:sort]))

    ### フィルタリング項目 ###
    @filtering_makers = @catalogs.group(:maker).order(count: :desc).limit(100).count
    @filtering_genres = CatalogGenre.joins(:genre).where(catalog: @catalogs).group(:genre_id, "genres.genre").order(count: :desc).limit(100).count

    # filter check 用
    @fc_genres = @filtering_genres.map { |k, v| { target: :genre_ids, label: k[1], value: k[0], count: v, cls: "col-2" } }
    @fc_makers = @filtering_makers.map { |k, v| { target: :makers, label: k, value: k, count: v, cls: "col-2" } }

    # ソート
    @catalogs = @catalogs.order(:maker, :models)
  end

  def check_rank
    redirect_to "/admin", alert: "電子カタログの表示権限がありません" unless current_company&.check_rank(:b_member)
  end

  def catalog_request_params
    params.require(:admin_catalog_request_form).permit(:maker, :model, :comment)
  end
end
