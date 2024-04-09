class System::CrawlerController < ApplicationController
  before_action :set_company, only: [:edit, :update]

  def edit
    @machines = @company.machines.where.not(used_id: nil)

    @machines = @machines.where.not(used_change: nil) if params[:update].present?
    puts @machines.to_sql
    @used_ids = @machines.pluck(:used_id)

    render json: @used_ids
  end

  def update
    used_ids = JSON.parse(params[:used_ids], symbolize_names: true)

    ### 一括削除 ###
    @company.machines.where.not(used_id: nil).where.not(used_id: used_ids).soft_delete_all

    ### 登録 ###
    datas = JSON.parse(params[:datas], symbolize_names: true)

    ### ジャンルリスト作成 ###
    genres = CSV.open("/assets/csv/crawl_genres.csv", headers: true).to_h { |row| [row[0], row[1]] }

    datas.each do |da|
      @machine = find_or_initialize_by(used_id: da[:uid])

      @machine.assign_attributes(da)

      # genre
      @machine[:hint]     = da[:hint].upcase
      @machine[:genre_id] = genres[@machine[:hint]] || Genre::OTHERS_GENRE_ID

      # location
      if da[:location] == "本社"
        @machine.assign_attributes(addr1: @company.addr1, addr2: @company.addr2, addr3: @company.addr3)
      elsif office = @company.offices_parsed.datas.find { |_, v| v[:name] == da[:location] }
        @machine.assign_attributes(addr1: office[:addr1], addr2: office[:addr2], addr3: office[:addr3])
      end

      # 保存
      @machine.save

      ### リレーション先(images, pdfs)の処理 ###

      # images
      # 旧画像処理がある場合はスキップ
      if @machine.top_img.blank?
        da[:used_image].each do |im|
          # トップ画像
          if @machine.top_image.blank?
            @machine.remote_top_image_url = im
            @machine.save
          elsif @machine.top_images.image.filename == im || @machine.image_images.find_by(image: im)
            # なにもしない
          else
            image = @machine.image_images.new
            image.remote_image_url = im
            image.save
          end
        end
      end

      # PDFs
      # 旧PDFがある場合はスキップ
      if @machine.pdfs_parsed.datas.blank?
        da[:used_pdfs].each do |k, pdf|
          pdf = @machine.image_pdfs.find_or_initialize_by(pdf:)

          pdf.remote_image_url = pdf
          pdf.update(name: k)
        end
      end
    end
  end

  private

  def set_company
    @company = Company.find_by!(id: params[:id], company: params[:company])
  rescue StandardError
    render json: "会社情報がありません。"
  end
end
