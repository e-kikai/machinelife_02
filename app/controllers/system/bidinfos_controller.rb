class System::BidinfosController < System::ApplicationController
  before_action :set_bidinfo, only: %i[edit update destroy]

  def index
    @bidinfos = Bidinfo.order(id: :desc)
  end

  def new
    @bidinfo_form = System::BidinfoForm.new
  end

  def edit
    @bidinfo_form = System::BidinfoForm.new(bidinfo: @bidinfo)
  end

  def create
    @bidinfo_form = System::BidinfoForm.new(bidinfo_params)

    if @bidinfo_form.save
      redirect_to "/system/bidinfos", notice: "入札会バナー情報を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @bidinfo_form = System::BidinfoForm.new(bidinfo_params, bidinfo: @bidinfo)

    if @bidinfo_form.save
      redirect_to "/system/bidinfos", notice: "入札会バナー情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bidinfo.soft_delete

    redirect_to "/system/bidinfos", status: :see_other, notice: "入札会バナー情報を削除しました。"
  end

  private

  def set_bidinfo
    @bidinfo = Bidinfo.find(params[:id])
  end

  def bidinfo_params
    params.require(:system_bidinfo_form)
      .permit(:bid_name, :uri, :organizer, :place, :preview_start_date, :preview_end_date, :bid_date, :banner_image, :banner_image_delete)
  end
end
