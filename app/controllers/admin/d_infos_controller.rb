class Admin::DInfosController < ApplicationController
  before_action :check_daihou
  before_action :set_d_info, only: %i[edit update destroy]

  def index
    @d_infos = current_company.d_infos.order(info_date: :desc)
    @pagy, @pd_infos = pagy(@d_infos) # ページャ
  end

  def new
    @d_info_form = Admin::DInfoForm.new(d_info: current_company.d_infos.build)
  end

  def edit
    @d_info_form = Admin::DInfoForm.new(d_info: @d_info)
  end

  def create
    @d_info_form = Admin::DInfoForm.new(d_info_params, d_info: current_company.d_infos.build)

    if @d_info_form.save
      redirect_to "/admin/d_infos", notice: "自社サイト お知らせを保存しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @d_info_form = Admin::DInfoForm.new(d_info_params, d_info: @d_info)

    if @d_info_form.save
      redirect_to "/admin/d_infos", notice: "自社サイトのお知らせを保存しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @d_info.soft_delete

    redirect_to "/admin/d_infos", status: :see_other, notice: "自社サイトのお知らせを削除しました。"
  end

  private

  def d_info_params
    params.require(:admin_d_info_form).permit(:info_date, :title, :contents)
  end

  ### 現状は大宝機械専用 ###
  def check_daihou
    redirect_to "/admin/", notice: "現在、このページには入れません。" if current_company&.id != DInfo::DAIHOU_COMPANY_ID
  end

  def set_d_info
    @d_info = current_company.d_infos.find(params[:id])
  end
end
