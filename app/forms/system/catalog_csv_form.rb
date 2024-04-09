class System::CatalogCsvForm < FormBase
  attribute :csv_file
  attribute :catalogs, default: []

  def initialize(attributes = nil)
    super(attributes)
  end

  ### カタログCSVアップロード＆インポート確認 ###
  def upload
    raise ActiveRecord::ActiveRecordError 'CSVファイルを選択してください' if csv_file.blank?

    ### ジャンル一覧の取得 ###
    genre_list = Genre.pluck(:genre, :id).to_h

    CSV.foreach(csv_file.path, { headers: true, encoding: Encoding::SJIS }) do |row|
      uid = row[0]
      next if uid.empty? || uid == "uid"

      attrs = {
        uid:,
        maker: row[1],
        maker_kana: row[2],
        genre_ids: row[3].split("\n").filter_map { |g| genre_list[g] },
        year: row[4],
        catalog_no: row[5],
        models: row[6..].compact.join(', ').strip
      }

      catalogs << CatalogForm.new(attrs)
    end

    raise ActiveRecord::ActiveRecordError 'カタログ情報がありませんでした' if catalogs.blank?
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error([e.message, *e.backtrace].join($RS))
    errors.add(:base, e.message)

    false
  end

  def persist
    # 保存トランザクション
    ActiveRecord::Base.transaction do
      catalogs.each do |ca|
        CatalogForm.new(ca).save
      end
    end
  end
end
