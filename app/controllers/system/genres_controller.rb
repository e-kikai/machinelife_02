class System::GenresController < System::ApplicationController
  before_action :set_genre, only: %w[edit update destroy]
  before_action :set_new, only: %w[new create]

  def new
    @genre_form = System::GenreForm.new(genre: @genre)
  end

  def edit
    @genre_form = System::GenreForm.new(genre: @genre)
  end

  def create
    @genre_form = System::GenreForm.new(genre_params, genre: @genre)

    if @genre_form.save
      redirect_to "/system/large_genres/#{@genre.large_genre_id}", notice: "ジャンルを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @genre_form = System::GenreForm.new(genre_params, genre: @genre)

    if @genre_form.save
      redirect_to "/system/large_genres/#{@genre.large_genre_id}", notice: "ジャンルを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @genre.soft_delete

    redirect_to "/system/arge_genres/#{@genre.large_genre_id}", status: :see_other, notice: "ジャンル : #{@genre.genre} を削除しました。"
  end

  private

  def set_new
    @large_genre = LargeGenre.find(params[:large_genre_id])
    @genre = @large_genre.genres.new
  end

  def set_genre
    @genre = Genre.find(params[:id])
  end

  def genre_params
    params.require(:system_genre_form).permit(:genre_name, :genre_kana, :order_no, :capacity_label, :capacity_unit, :naming, :spec_labels)
  end
end
