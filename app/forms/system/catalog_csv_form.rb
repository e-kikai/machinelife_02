class System::CatalogCsvForm < FormBase
  attribute :csv_file
  attribute :catalogs, default: []

  def initialize(attributes = nil)
    super(attributes)
  end

  ### カタログCSVアップロード＆インポート確認 ###
  def upload
    raise "CSVファイルを選択してください" if csv_file.blank?

    ### ジャンル一覧の取得 ###
    genre_list = Genre.pluck(:genre, :id).to_h

    catalogs = CSV.open(csv_file.path, headers: true, encoding: Encoding::SJIS).map do |row|
      uid = row[0]
      next if uid.empty? || uid == "uid"

      models = row[6..].compact.join(', ').strip

      {
        uid:,
        maker: row[1],
        maker_kana: row[2],
        genre_ids: row[3].split("\n").filter_map { |gname| genre_list[gname] },
        year: row[4],
        catalog_no: row[5],
        models:,
        keywords: Machine.to_model2(models),
        catalog_id: Catalog.find_by(uid:)&.id,
        exsist: File.exist?(filepath(uid)) # ファイルの有無
      }
    end

    raise 'カタログ情報がありませんでした' if catalogs.blank?

    assign_attributes(catalogs:)
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error([e.message, *e.backtrace].join($RS))
    errors.add(:base, e.message)

    false
  end

  def persist
    # 保存トランザクション
    catalogs.each do |ca|
      next unless ca[:exsist]

      catalog = Catalog.where.not(id: nil).find_or_initialize_by(id: ca[:catalog_id])

      catalog.assign_attributes(ca.except(:catalog_id, :exsist))

      # カタログファイルを格納
      File.open(filepath(ca[:uid])) { |file| catalog.pdf = file }

      catalog.update(changed_at: Time.current)
    end
  end

  private

  def filepath(uid)
    "#{Catalog::UPLOAD_PATH}/#{uid}.pdf"
  end
end
