class System::XlGenresController < System::ApplicationController
  before_action :set_xl_genre, only: %w[show edit update destroy]

  def index
    @xl_genres = XlGenre.order(:order_no, :id)
  end

  def show
    @large_genres = @xl_genre.large_genres.order(:order_no, :id)
  end

  def new
    @xl_genre_form = System::XlGenreForm.new
  end

  def edit
    @xl_genre_form = System::XlGenreForm.new(xl_genre: @xl_genre)
  end

  def create
    @xl_genre_form = System::XlGenreForm.new(xl_genre_params)

    if @xl_genre_form.save
      redirect_to "/system/xl_genres", notice: "特大ジャンルを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @xl_genre_form = System::XlGenreForm.new(xl_genre_params, xl_genre: @xl_genre)

    if @xl_genre_form.save
      redirect_to "/system/xl_genres", notice: "特大ジャンルを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @xl_genre.soft_delete

    redirect_to "/system/xl_genres", status: :see_other, notice: "特大ジャンル : #{@xl_genre.xl_genre} を削除しました。"
  end

  private

  def set_xl_genre
    @xl_genre = XlGenre.find(params[:id])
  end

  def xl_genre_params
    params.require(:system_xl_genre_form).permit(:xl_genre_name, :xl_genre_kana, :icon, :order_no)
  end
end
