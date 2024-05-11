class System::InfosController < System::ApplicationController
  before_action :set_info, only: %w[edit update destroy]

  def index
    @infos = Info.order(id: :desc)

    @pagy, @pinfos = pagy(@infos, items: 50)
  end

  def new
    @info_form = System::InfoForm.new
  end

  def edit
    @info_form = System::InfoForm.new(info: @info)
  end

  def create
    @info_form = System::InfoForm.new(info_params)

    if @info_form.save
      redirect_to "/system/infos", notice: "お知らせを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @info_form = System::InfoForm.new(info_params, info: @info)

    if @info_form.save
      redirect_to "/system/infos", notice: "お知らせを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @info.soft_delete

    redirect_to "/system/infos", status: :see_other, notice: "#{@info.id}\ : #{@info.info_name} のお知らせを削除しました。"
  end

  private

  def set_info
    @info = Info.find(params[:id])
  end

  def info_params
    params.require(:system_info_form).permit(:info_date, :target, :group_id, :contents)
  end
end
