class System::LargeGenresController < System::ApplicationController
  before_action :set_large_genre, only: %w[show edit update destroy]
  before_action :set_new, only: %w[new create]

  def show
    @genres = @large_genre.genres.order(:order_no, :id)
  end

  def new
    @large_genre_form = System::LargeGenreForm.new(large_genre: @large_genre)
  end

  def edit
    @large_genre_form = System::LargeGenreForm.new(large_genre: @large_genre)
  end

  def create
    @large_genre_form = System::LargeGenreForm.new(large_genre_params, large_genre: @large_genre)

    if @large_genre_form.save
      redirect_to "/system/xl_genres/#{@large_genre.xl_genre_id}", notice: "中ジャンルを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @large_genre_form = System::LargeGenreForm.new(large_genre_params, large_genre: @large_genre)

    if @large_genre_form.save
      redirect_to "/system/xl_genres/#{@large_genre.xl_genre_id}", notice: "中ジャンルを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @large_genre.soft_delete

    redirect_to "/system/xl_genres/#{@large_genre.xl_genre_id}", status: :see_other, notice: "中ジャンル : #{@large_genre.large_genre} を削除しました。"
  end

  private

  def set_new
    @xl_genre = XlGenre.find(params[:xl_genre_id])
    @large_genre = @xl_genre.large_genres.new
  end

  def set_large_genre
    @large_genre = LargeGenre.find(params[:id])
  end

  def set_form
    @large_genre_form = System::LargeGenreForm.new(large_genre_params, large_genre: @large_genre)
  end

  def large_genre_params
    params.require(:system_large_genre_form).permit(:large_genre_name, :large_genre_kana, :order_no)
  end
end
