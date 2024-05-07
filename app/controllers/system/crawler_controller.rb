class System::CrawlerController < ApplicationController
  require 'csv'

  before_action :set_company, only: [:edit, :update]
  protect_from_forgery with: :null_session

  def edit
    @machines = @company.machines.where.not(used_id: nil)

    @machines = @machines.where.not(used_change: nil) if params[:update].present?
    @used_ids = @machines.pluck(:used_id)

    render json: @used_ids
  end

  def update
    ### JSONデコード ###
    rex = JSON.parse(params[:rex], symbolize_names: true, allow_nan: true)
    datas = JSON.parse(params[:datas], symbolize_names: true, allow_nan: true)

    ### 一括削除 ###
    delete_machines = @company.machines.where.not(used_id: nil).where.not(used_id: rex)

    delete_count = delete_machines.count
    delete_machines.soft_delete_all

    ### ジャンルリスト作成 ###
    genres = CSV.open(Rails.root.join("crawlers/csv/crawl_genres.csv").to_s, headers: true, encoding: 'sjis').to_h { |row| [row[0], row[1]] }

    ### 登録 ###
    create_count = 0
    update_count = 0

    datas.each do |da|
      next if da[:uid].blank?

      machine = @company.machines.with_deleted.find_or_initialize_by(used_id: da[:uid])

      machine.new_record? ? create_count += 1 : update_count += 1

      attrs = %i[no name maker model year capacity spec accessory comment location addr1 addr2 addr3 commission youtube ekikai_price price]
      machine.assign_attributes(attrs.index_with { |attr| da[attr] })

      # genre_id
      hint = da[:hint]&.upcase
      machine.assign_attributes({ hint:, genre_id: genres[hint] || Genre::OTHERS_GENRE_ID, deleted_at: nil })

      # location
      if da[:location] == "本社"
        machine.assign_attributes({ addr1: @company.addr1, addr2: @company.addr2, addr3: @company.addr3 })
      elsif office = @company.offices_parsed.datas.find { |_, v| v&[:name] == da[:location] }
        machine.assign_attributes({ addr1: office[:addr1], addr2: office[:addr2], addr3: office[:addr3] })
      end

      # images(旧画像処理がある場合はスキップ)
      images_res = []
      if machine.top_img.blank? && da[:used_imgs].present?
        images = machine.machine_images.pluck(:image)

        da[:used_imgs]&.each do |im|
          filename = File.basename(Addressable::URI.parse(im).path)

          if machine.top_image.blank?
            machine.remote_top_image_url = im # トップ画像に格納
          elsif machine[:top_image] != filename && images.exclude?(filename)
            images_res << { remote_image_url: im } # その他画像に格納
          end
        end
      end

      # 保存
      # machine.update(changed_at: Time.current) if machine.changed?
      machine.save if machine.changed?

      ### リレーション先(images, pdfs)の処理 ###
      # threads = images_res.filter_map do |im_attr|
      #   Thread.new { machine.machine_images.create(im_attr) }
      # end

      machine.machine_images.create(images_res) if images_res.present?

      # PDFs(旧PDFがある場合はスキップ)
      if machine.pdfs_parsed.datas.blank? && da[:used_pdfs].present?
        pdfs = machine.machine_pdfs.pluck(:pdf)

        da[:used_pdfs]&.filter_map do |k, pdf|
          filename = File.basename(Addressable::URI.parse(pdf).path)
          machine.machine_pdfs.create(remote_pdf_url: pdf, name: k) if pdfs.exclude?(filename)
        end

        # threads.concat(
        #   da[:used_pdfs]&.filter_map do |k, pdf|
        #     Thread.new do
        #       filename = File.basename(Addressable::URI.parse(pdf).path)
        #       machine.machine_pdfs.create(remote_pdf_url: pdf, name: k) if pdfs.exclude?(filename)
        #     end
        #   end
        # )
      end

      # threads.each(&:join) # スレッドを結合
    rescue StandardError => e
      puts e
    end

    render plain: "#{delete_count} machines delete. / #{update_count} machines update / #{create_count} machines insert success."
  end

  private

  def set_company
    @company = Company.find_by!(id: params[:id], company: params[:company])
  rescue StandardError
    render json: "会社情報がありません。"
  end
end
