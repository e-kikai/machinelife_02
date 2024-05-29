class System::UsedCsvForm < FormBase
  attribute :company_id, :integer
  attribute :csv_file
  attribute :machines, default: []
  attribute :used_company_id, :integer

  USED_DETAIL_PATH = 'https://www.jp.usedmachinery.bz/machines/general_view'.freeze
  USED_IMAGE_PATH = 'https://www.jp.usedmachinery.bz/assets/images/jpmachines'.freeze

  def initialize(attributes = nil)
    super(attributes)
  end

  ### カタログCSVアップロード＆インポート確認 ###
  def upload
    raise "CSVファイルを選択してください" if csv_file.blank?

    set_company # 会社情報

    # 現在登録されている在庫取得
    used_machines = @company.machines.where.not(used_id: nil).pluck(:used_id)

    # ジャンルリスト作成
    genres = CSV.open(Rails.root.join("crawlers/csv/crawl_genres.csv").to_s, headers: true, encoding: 'sjis').to_h { |row| [row[0], row[1].to_i] }
    genres.merge!(Genre.all.to_h { |ge| [ge.genre, ge.id] })

    machines = CSV.open(csv_file.path, headers: true, encoding: Encoding::SJIS).map do |row|
      # row = row.to_a.map(&:strip).map { |c| row[1] == '-' ? "" : c }

      used_id = row[0]
      next if used_id.empty? || used_id == "機械ID"

      name = row[4]

      {
        used_id:,
        no: row[1],
        name:,
        maker: row[5],
        model: row[6],
        year: row[7],
        spec: row[8],
        accessory: row[9],
        comment: row[10],
        price: row[15].to_i.positive? ? row[15].to_i * 10_000 : "",
        addr1: row[16].gsub(/\(.*\)/, ""),
        location: "本社",
        images: row[20..27].compact,
        pdf: row[28],
        youtube: row[29],
        commission: row[31] == '試運転可' ? 1 : 0,
        genre_id: genres[name] || Genre::OTHERS_GENRE_ID,
        present: used_machines.include?(used_id) ? used_id : nil
      }
    end

    raise '機械情報がありませんでした' if machines.blank?

    assign_attributes(machines:)

    # 百貨店の会社IDを取得
    url = "#{USED_DETAIL_PATH}/#{machines.first[:used_id]}"
    page = NKF.nkf("-wZX--cp932", URI.parse(Addressable::URI.parse(url).normalize.to_s).read)
    p = Nokogiri::HTML(page, nil, 'UTF-8')
    assign_attributes(used_company_id: p.at("a.mod-text__link:contains('この企業の全ての在庫')")[:href].slice(/[0-9]*$/))
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error([e.message, *e.backtrace].join($RS))
    errors.add(:base, e.message)

    false
  end

  def persist
    set_company # 会社情報

    # 保存トランザクション
    ActiveRecord::Base.transaction do
      @company.machines.where.not(used_id: nil).where.not(used_id: machines.pluck(:present).compact).soft_delete_all # 削除

      machines.select { |ma| ma[:present].blank? }.each do |data|
        machine = @company.machines.with_deleted.find_or_initialize_by(used_id: data[:used_id].presence || "xxx")

        machine.assign_attributes(data.except(:images, :pdf, :present))
        machine.update(deleted_at: nil)

        # 画像
        next if machine.top_image.present? # 重複回避

        images_res = []
        data[:images]&.each do |im|
          filename = filepath(data[:used_id], im)

          if machine.top_image.blank?
            machine.remote_top_image_url = filename # トップ画像に格納
          else
            images_res << { remote_image_url: filename } # その他画像に格納
          end
        end

        machine.save if machine.changed?
        machine.machine_images.create(images_res) if images_res.present?

        # PDF
        if data[:pdf].present?
          filename = filepath(data[:used_id], data[:pdf])
          machine.machine_pdfs.create(remote_pdf_url: filename, name: "PDF")
        end
      end
    end
  end

  # 会社選択肢
  def select_companies
    Group.includes(:companies).order(:parent_id, :id, "companies.id")
  end

  def filepath(used_id, file)
    "#{USED_IMAGE_PATH}/#{used_company_id}/#{used_id}/#{file}"
  end

  private

  def set_company
    redirect_to "/system/machines/csv", alert: '出品会社を選択してください' if company_id.blank?

    @company = Company.find(company_id)
  end
end
