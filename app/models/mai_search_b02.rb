class MaiSearchB02
  PRODUCTS_LIMIT  = 120
  RESULT_LIMIT    = 60
  REPORT_LIMIT    = 300
  REQUEST_TIMEOUT = 30

  IGNORE_WORDS = /\|?(切削工具|不明|工作機械|測定工具|中古)\|?/
  NC_WORDS     = /旋盤|フライス|研削|研磨|ボール|自動|彫刻|中ぐり/
  NORMALIZATION_MAP = [
    %w[一 1],
    %w[二 2],
    %w[三 3],
    %w[四 4],
    %w[五 5],
    %w[六 6],
    %w[七 7],
    %w[八 8],
    %w[九 9]
  ].freeze

  SYSTEM_MESSAGE = "
あなたは「全日本機械業連合会（全機連）」が運営する、中古工作機械・工具の販売サイト「マシンライフ」のAIアシスタント「MAI」です。
MAIは、中古機械・工具に精通した丁寧な口調の美人眼鏡秘書であり、プロフェッショナル向けに商品提案を行います。

ユーザーは、工作機械・工具の専門知識を持つ技術者や販売商社です。
彼らの質問に対し、マシンライフの在庫情報から適切な機械・工具を提案し、購入の意思決定をサポートしてください。
".freeze

  QUERY_MESSAGE = '
ユーザーの入力した検索条件から、適切な機械・工具をRDSで検索するための**正規表現ベースの検索キーワード**を生成してください。

## 処理
1. 入力から、適切な機械・工具を特定するためにキーワード分割してください。
2. キーワードを以下の項目に分類し、正規表現化してください。
3. 出力は**固定JSONフォーマット**で作成してください。

## 出力JSONフォーマット
- name: 機械・工具の一般名称（表記ゆれ・略称などを正規表現で列挙）
- name2: 機械・工具の一般名称（あいまい検索なし、単一の名称）
- maker: メーカー名の固有名詞部分（例：アマダ、オークマ、滝沢）
- model: 型式（半角英数字大文字に統一）
- min_year / max_year: 年式（西暦4桁、範囲指定可能）
- addr1: 都道府県名、正式名称で列挙
- addr2: 市区町村名、正式名称で列挙
- min_date / max_date: 登録日（フォーマット:YYYY/MM/DD、範囲指定可能）
- capacity: 能力・寸法などの数値と単位（正規表現）
- img(画像あり) / youtube(動画あり) / commission(試運転可) / catalog(電子カタログあり) : 対応が必要なら 1 を指定

## 出力例
ex.1) 大阪近辺で、オークマかアマダの90年代の5尺立型旋盤の型式がLSかods-12で。
ans.1)
{"name": "((立||立型|縦)旋盤))|タテセンバン", "name2": "立旋盤", "maker": "オークマ|アマダ", "min_year": "1990", "max_year": "1999", "model": "LS|ODS12", "addr1": "大阪府", "capacity": "5尺"}

ex.2) 東京近郊でアマダ製バンドソー250mm、動画があるもの
ans.2)
{"name": "バンドソ|帯鋸|バンドノコ", "name2": "バンドソ", "maker": "アマダ", "addr1": "東京都|千葉県|埼玉県|神奈川県", "capacity": "(250(mm|ミリメートル|粍))", "youtube":"1"}

ex.3) 東大阪にある7.5kwパッケージコンプレッサー、アネスト岩田製
ans.3)
{"name": "((パッケージ|パッケージ型)コンプレッサ)|コンプレッサ", "name2": "パッケージコンプレッサ", "maker": "岩田", "addr1": "大阪府", "addr2": "東大阪市", "capacity": "(7.5(kw|キロワット))"}

ex.5) 大阪周辺にある相澤鐵工所1990年製の1000mm以上のメカシャーリング。
ans.4)
{"name": "シャーリング|メカシャー", "name2": "シャーリング", "maker": "相澤", "min_year": "1990", "max_year": "1990, "addr1": "大阪府|兵庫県|京都府|奈良県|和歌山県", "capacity": "([1-9][0-9][0-9][0-9](mm|ミリメートル|粍))"}

ex.5) 関西にある山崎のNC立フライス、2005年以降。
ans.5)
{"name": "NCフライス|NC立フライス|NC立型フライス", "name2": "NC立フライス", "maker": "ヤマザキ|山崎", "min_year": "2005", "addr1": "大阪府|兵庫県|京都府|奈良県|和歌山県"}

ex.6)  1995年以降の大阪にある滝沢の6尺旋盤で、試運転ができるもの
ans.6)
{"name": "旋盤", "name2": "旋盤", "maker": "滝沢", "min_year": "1995", "addr1": "大阪府", "capacity": "6尺", "commission": "1"}

ex.7)  静岡鉄工のマシニング
ans.7)
{:name=>"マシニング|マシニングセンタ|MC", :name2=>"マシニングセンタ", :maker=>["静岡"]}

## ルール
-  ' + "- 今日の日付は#{Time.zone.today}" + '
- キーワード分類の優先順位は、 model > maker > name > addr1 > addr2 > capacity > その他の順。
- name では類義語を | で並べる (例: バンドソ|帯鋸|バンドノコ)。特徴語(油圧プレスの油圧、石定盤の石、など)は、必ずマッチするように。
- capacity は正規表現化 (例: ([1-9][0-9][0-9][0-9](mm|ミリメートル|粍)))
- maker は固有名詞のみ、
- 英数記号のみのものは、 name ではなく model に (例 : B-Y-40 -> model: BY40, name: nil)
- 正規表現では語尾の長音「ー」は除く
- min_data、max_date、「新着」はmin_date:1週間前の日付,max_date:今日を取得、ピンポイントな日付はmaxとmin同一の日付を取得
- 値のない項目は出力しないでください。
'.freeze

  SORT_QUERY_MESSAGE = '
## 処理
<machines>は、マシンライフの在庫機械・工具から検索した結果JSONです。
id ごとに1つの機械情報になっています。

messageには、<machines>を検索したときの検索条件が入力されます。

以下の処理結果を必ず出力フォーマットのJSON形式で出力してください。

1. 検索結果の機械情報を巡回し、機械ごとのデータをよく分析・理解してください。

2. 検索結果の機械情報を巡回し、ユーザが購入する際の商品選定基準になる項目を1~2項目考えてください。
- 項目から、型式、年式、メーカーは除外してください。

3. 選定基準の項目についての説明、具体的な選定方法のアドバイスを200文字程度までで"report"に出力してください。
- 選定基準の項目名の部分は[[項目]]としてください。

4. 検索結果の機械情報を巡回し、機械IDごとの選定基準の項目の値を取得して、"specs"に出力してください。
- 情報は出品会社各社が自由に入力するため、記述方法がバラバラです。
例えば、
  - 「300mmハイトゲージ」のように name に値だけ含まれている
  - model, spec に値だけ記述されている
  - 項目名が違うもの、省略形のもの、項目名なしのもの(加工能力と切断能力、オープンハイトをOH、ストロークをSなど)
これらを考慮して、間違ってもいいので、取りこぼさないようできるだけ値を取得してください。
- capacity に項目の内容があれば"必ず"値を取得してください。
- 各項目で単位表記を統一してください(例 : 「T」「トン」「t」「ton」はすべて 「T」に統一)。単位のないものは補完してください。
- 値がないもの不明なものは除外してください。

## 出力フォーマット
{
"report": "3.のアドバイスをここに記述",
"specs":
{
"項目A": {
"231381": "120mm",
"284232": "500mm",
"307832": "360mm"
},
"項目B": {
"231385": "60T",
"284299": "30T",
"307882": "100T"
}
}
'.freeze

# 1. 検索結果の機械情報を巡回し、messageの検索条件に全くマッチしていないゴミ情報をさがして、「id」を"ids"に列挙してください。

# 例えば、
#   - 「300mmハイトゲージ」のように name に含まれている
#   - model, spec に数値だけ記述されている
#   - 項目名が違うもの、省略形のもの、項目名なしのもの(加工能力と切断能力、オープンハイトをOH、ストロークをSなど)
# これらを考慮して、間違ってもいいので、取りこぼさないよう、できるだけ値を取得してください。

# 1. 検索結果の機械情報のうち、messageの検索内容を解釈し、
# 検索条件にマッチするものの「id」を"ids"に列挙してください。
# 条件にマッチするかは、広めにとってください。全くマッチしていないもののみ除外してください。

  attr_reader(
    :message, :count, :level, :wheres, :machines, :advice, :adv_machines,
    :filtering_makers, :filtering_addr1s, :filtering_years, :filtering_capacities, :filtering, :filters, :specs, :spec_labels , :spec_by_model
  )

  def initialize(message: "", filters: {})
    @message = message
    @filters = filters

    @count        = 0
    @level        = 0
    @wheres       = {}
    @machines     = Machine.none
    @adv_machines = Machine.none
    @advice       = ""
    @specs        = {}
    @spec_labels  = []

    @filtering = false
    @filtering_makers     = {}
    @filtering_addr1s     = {}
    @filtering_years      = {}
    @filtering_capacities = {}
  end

  def call
    # 質問文が英数字だけのとき
    kwd = self.class.to_model_keywords(@message)

    if kwd.present? && kwd.join =~ /^[0-9A-Z\s]*$/
      @machines = Machine.mai_search_sales.where("machines.search_keyword ~* ALL(ARRAY[?])", kwd)
      @count    = @machines.count

      @wheres[:kwd] = kwd
      @level       += 1000

      return if @count.zero? # 結果なし
    end

    # ### 旧キーワード検索 ###
    # kwd = self.class.to_legacy_keywords(@message)

    # if kwd.present?
    #   # @machines = Machine.sales.includes(:contacts, :detail_logs).where(KEYWORD_SEARCH_SQL, kwd)
    #   @machines = Machine.mai_search_sales.where("machines.search_keyword ~* ALL(ARRAY[?])", kwd)
    #   @count    = @machines.count

    #   # if @count > PRODUCTS_LIMIT # 結果超過(画像のあるもののみ)
    #   #   @machines = @machines.with_images
    #   #   @count    = @machines.count
    #   #   @wheres[:kwd] = kwd
    #   #   @level       += 1600
    #   # elsif @count.positive? # 結果あり
    #   #   @wheres[:kwd] = kwd
    #   #   @level       += 1000
    #   # end

    #   if @count.positive? # 結果あり
    #     @wheres[:kwd] = kwd
    #     @level       += 1000
    #   end
    # end

    # # 質問文が英数字だけのとき、強制終了
    # if @count.zero? && kwd.join =~ /^[0-9A-Z\s]*$/
    #   @wheres[:kwd] = kwd
    #   @level       += 1000
    #   return
    # end

    ### キーワード抽出検索 ###
    if @count.zero?

      ### 過去ログがあれば、キーワードキャッシュ取得 ###
      if mai_search_log = MaiSearchLog.message_cache(@message).first
        where_json = mai_search_log.keywords
        @wheres = JSON.parse(self.class.ignore_keyword(where_json || "{}"), symbolize_names: true)

        @level += 1
      end

      if @wheres.blank?
        response = client.chat(
          parameters: {
            model: "gpt-4o-mini",
            messages: [
              { role: "system", content: "#{SYSTEM_MESSAGE}\n#{QUERY_MESSAGE}" },
              { role: "user", content: @message }
            ],
            temperature: 0
          }
        )

        ### キーワードJSON抽出 ###
        generated_text = response.dig("choices", 0, "message", "content")

        begin
          where_json = generated_text.to_s.match(/(\{.*?\}|\[.*?\])/m)[0]
          @wheres = JSON.parse(self.class.ignore_keyword(where_json), symbolize_names: true) # JSONパース(除外ワード処理)
        rescue StandardError
          @wheres = {}
        end

        ### キーワード整形 ###
        # @wheres[:name]     = self.class.nc_keyword(@wheres[:name])
        set_name if @wheres[:name].present? # 機械名(NC)
        @wheres[:capacity] = self.class.capacity_keyword(@wheres[:capacity]) if @wheres[:capacity].present? # 能力
        @wheres[:maker]    = Maker.search_makers(@wheres[:maker].split('|')) if @wheres[:maker].present? # メーカー
      end

      ### search ###
      @machines = Machine.mai_search_sales

      # @machines = @machines.where("machines.maker ~* ?", maker_masters)           if @wheres[:maker].present? # メーカー
      if @wheres[:maker].present? # メーカー
        makers_where = Machine.where(maker: @wheres[:maker]).or(Machine.where('makers.maker_master': @wheres[:maker]))
        @machines    = @machines.merge(makers_where)
      end

      # @machines = @machines.where("machines.addr1 ~* ?", "^(#{@wheres[:addr1]})") if @wheres[:addr1].present? # 在庫場所
      @machines = @machines.where(addr1: @wheres[:addr1].split("|"))              if @wheres[:addr1].present? # 在庫場所
      @machines = @machines.where("machines.addr2 ~* ?", "(#{@wheres[:addr2]})")  if @wheres[:addr2].present? # 市区町村
      @machines = @machines.where("machines.name ~* ?", "(#{@wheres[:name]})")    if @wheres[:name].present? # 機械名
      @machines = @machines.where("machines.name !~* ?", "(#{@wheres[:name_not]})") if @wheres[:name_not].present? # 機械名(否定)
      @machines = @machines.where(year: ..@wheres[:max_year])                     if @wheres[:max_year].present? # 年式(最大)
      @machines = @machines.where(year: @wheres[:min_year]..)                     if @wheres[:min_year].present? # 年式(最小)
      @machines = @machines.where(created_at: ..@wheres[:max_date])               if @wheres[:max_date].present? # 登録日(最大)
      @machines = @machines.where(created_at: @wheres[:min_date]..)               if @wheres[:min_date].present? # 登録日(最小)
      @machines = @machines.where("machines.model2 ~* ?", @wheres[:model])        if @wheres[:model].present? # 型式
      @machines = @machines.where("machines.search_capacity ~* ?", "(^|[^0-9])+(#{@wheres[:capacity]})") if @wheres[:capacity].present? # 能力

      @machines = @machines.where(commission: 1) if @wheres[:commission].present? # 試運転
      @machines = @machines.where.not(youtube: [nil, "", "http://youtu.be/"]) if @wheres[:youtube].present? # youtube
      @machines = @machines.with_images if @wheres[:img].present? # 画像あり
      @machines = @machines.where.not(catalog_id: [nil, ""]) if @wheres[:catalog].present? # 電子カタログ

      ### (型式、キーワード抜きの)検索結果件数により条件の増減 ###
      @count  = @machines.count
      @level += 200

      if @count > PRODUCTS_LIMIT && @wheres[:name2].present? # 名前(より厳しく)条件追加
        name2_machines = @machines.where("machines.name ~* ?", @wheres[:name2])
        name2_count = name2_machines.count

        if name2_count.positive?
          @machines = name2_machines
          @count    = name2_count
          @level   += 100
        end
      end

      if @count > PRODUCTS_LIMIT # 画像があるもの
        img_machines = @machines.with_images
        img_count    = img_machines.count
        if img_count.positive?
          @machines = img_machines
          @count    = img_count
          @level   += 400
        end
      end
    end

    return if @count.zero? # (フィルタリング前の)検索結果が0場合、スキップ

    pre_machines = @machines

    ### フィルタリング処理 ###
    if @filters.present?
      @machines = @machines.where('makers.maker_master': @filters[:maker]) if @filters[:maker].present? # メーカー
      @machines = @machines.where(addr1: @filters[:addr1])                 if @filters[:addr1].present? # 都道府県
      @machines = @machines.where(year: @filters[:year].map { |y| (y.to_i)..(y.to_i + 9) }) if @filters[:year].present? # 年式
      # @machines = @machines.where(CAPACITY_SQL_ALL, "(^|[^0-9])+(#{@filters[:capacity].join('|')})") if @filters[:capacity].present? # 能力
      @machines = @machines.where("machines.search_capacity ~* ?", "(^|[^0-9])+(#{@filters[:capacity].join('|')})") if @filters[:capacity].present? # 能力

      @count    = @machines.count
      @level   += 10_000
    end

    ### フィルタリング候補(検索結果が0、超過の場合、アドバイススキップ) ###
    if @count.zero? || @count > PRODUCTS_LIMIT
      @filtering = true
      @filtering_makers     = pre_machines.where.not('makers.maker_master': [nil, '']).group("makers.maker_master").order(count: :desc).limit(19).count
      @filtering_addr1s     = pre_machines.where.not(addr1: [nil, '']).group(:addr1).order(count: :desc).limit(18).count
      @filtering_years      = pre_machines.where.not(year: [nil, '']).group("left(year, 3)").count
      @filtering_capacities = pre_machines.includes(:genre).where.not(capacity: [nil, 0]).where.not('genres.capacity_unit': [nil, ""])
        .group(:capacity, "genres.capacity_unit", "genres.capacity_label").order(capacity_label: :asc, capacity_unit: :asc, capacity: :asc).count
    else
      generate_advice
    end
  # rescue StandardError => e
  #   raise e.full_message
  #   # raise "MAI在庫検索処理でエラーが発生しました。"
  # end
  rescue StandardError => e
    # @error = e.full_message
    @error = e.message
    @error_mes = "MAIアドバイス生成処理でエラーが発生しました。"
    raise e
  end

  # 検索結果＆アドバイス生成
  def generate_advice
    system_message = "#{SYSTEM_MESSAGE}\n#{SORT_QUERY_MESSAGE}\n\n<machines>\n#{machines_json}"
    # machines_hash = @machines.pluck(:id, :search_keyword).map { |v| [id: v[0], info: v[1]] }
    # system_message = "#{SYSTEM_MESSAGE}\n#{SORT_QUERY_MESSAGE}\n\n<machines>\n#{machines_hash}"

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        # model: "gpt-4o",
        messages: [
          { role: "system", content: system_message },
          { role: "user", content: "#{@message} #{@filters.values}" }
        ],
        temperature: 0
      }
    )

    begin
      # 結果から、ID一覧を取得
      json_text = response.dig("choices", 0, "message", "content")
      json = JSON.parse(json_text)

      # search
      # @adv_machines =
      #   if json[:ids].present?
      #     Machine.sales.where(id: json[:ids]).order(model2: :asc, created_at: :desc)
      #   else
      #     @machines.order(model2: :asc, created_at: :desc)
      #   end
      # @adv_machines = @machines.order(model2: :asc, created_at: :desc)

      @adv_machines = @machines.order(model2: :asc, created_at: :desc)
      # @adv_machines = @adv_machines.where.not(id: json[:ids]) if json[:ids].present?

      # レポート整理
      @advice = json["report"].gsub('。', "。\n")

      # 項目整理
      specs_temp = (json["specs"].presence || {})
        .transform_values { |v| v.reject { |_, v2| v2.blank? || v2 == "不明" || v2 == "-" } }

      @spec_labels = specs_temp.keys

      @spec_labels.each_with_index do |label, i|
        specs_temp[label].each do |id, v|
          @specs[id.to_i] ||= []
          @specs[id.to_i][i] = v
        end
      end

      # 能力値補完(型式)
      spec_by_model = {}

      @machines.each do |ma|
        next if ma.model2.blank? || ma.model2.length <= 3 || @specs[ma.id].blank?

        spec_by_model[ma.model2] ||= []
        @specs[ma.id].each_with_index { |v, i| spec_by_model[ma.model2][i] = v if spec_by_model[ma.model2][i].blank? }
      end

      @spec_by_model = spec_by_model

      @machines.each do |ma|
        next if ma.model2.blank? || ma.model2.length <= 3 || spec_by_model[ma.model2].blank?

        @specs[ma.id] ||= []
        spec_by_model[ma.model2].each_with_index { |v, i| @specs[ma.id][i] = v if @specs[ma.id][i].blank? }
      end

      @spec_by_model = spec_by_model
    rescue StandardError => e
      # @error = e.full_message
      @error = e.message
      @error_mes = "MAIアドバイス生成処理でエラーが発生しました。"
    end
  end

  # JSON用ハッシュ生成
  def self.to_json_hash(machine)
    res = {
      id: machine.id,
      name: machine.name,
      maker: machine.maker,
      model: machine.model,
      year: machine.myear,
      spec: machine.spec,
      accessory: machine.accessory,
      comment: "#{machine.comment} ",
      location: "#{machine.addr1} #{machine.addr2}",
      # location: "#{machine.addr1} #{machine.addr2} #{machine.addr3} (#{machine.location})",
      # category: machine.xl_genre.xl_genre,
      # large_genre: machine.large_genre.large_genre,
      # genre: machine.genre.genre,
      capacity: machine.capacities,
      # registration_date: machine.created_at.strftime("%y/%m/%d %H:%M:%S"),
      # access_count: machine.detail_logs.size,
      # contact_count: machine.contacts.size
      # "添付PDF": machine.pdfs_parsed.medias.map(&:name)
    }

    # comment
    res[:comment] += machine.top_img.present? || machine.top_image.present? ? " 画像あり" : " 画像なし"
    res[:comment] += " 試運転可"         if machine.commission == 1
    res[:comment] += " YouTube動画あり"  if machine.youtube.present?
    res[:comment] += " 電子カタログあり" if machine.catalog_id.present?
    res[:comment] += " 商談中" if machine.view_option == "negotiation"

    res.reject { |_, value| value.blank? || value == '-' }

    res
  end

  # 機械情報のJSON変換
  def machines_json
    # @machines.includes(:company, :genre, :large_genre, :xl_genre, :machine_pdfs, :contacts, :detail_logs)
    # @machines.includes(:company, :genre, :large_genre, :xl_genre, :contacts, :detail_logs)
    @machines.includes(:company)
      .map { |ma| self.class.to_json_hash(ma) }.to_json
  end

  # 旧キーワード検索
  def self.to_legacy_keywords(keyword)
    NKF.nkf('-wXZ', ignore_keyword(keyword)).upcase.gsub(/[　]/, " ").gsub(/[[:punct:]]/, "").split(/[[:space:]]/)
      .map { |k| Maker.makers_keyword(k) }
      .map { |k| nc_keyword(capacity_keyword(k)).gsub(/[ー-]$/, '') }
      .compact_blank
  end

  def self.to_model_keywords(keyword)
    NKF.nkf('-wXZ', ignore_keyword(keyword)).upcase.gsub(/[　]/, " ").gsub(/[[:punct:]]/, "").split(/[[:space:]]/).compact_blank
  end

  def self.capacity_keyword(kwd)
    kwd
      .gsub(/3尺|360mm|0.36m/i, '(3尺|360mm|0.36m)')
      .gsub(/4尺|500mm|550mm|0.5m|0.55m/i, '(4尺|500mm|550mm|0.5m|0.55m)')
      .gsub(/5尺|600mm|0.6m/i, '(5尺|600mm|0.6m)')
      .gsub(/6尺|800mm|0.8m/i, '(6尺|800mm|0.8m)')
      .gsub(/7尺|1000mm|1.0m/i, '(7尺|1000mm|1.0m)')
      .gsub(/8尺|1250mm|1.25m /i, '(8尺|1250mm|1.25m)')
      .gsub(/9尺|1500mm|1.5m/i, '(9尺|1500mm|1.5m)')
  end

  def self.ignore_keyword(kwd)
    kwd.gsub(IGNORE_WORDS, '')
  end

  def self.nc_keyword(kwd)
    kwd.gsub!(/CNC/i, 'NC')
    kwd = "(?<!NC)(#{kwd})" if kwd =~ NC_WORDS && kwd !~ /NC/i

    kwd
  end

  def set_name
    name     = @wheres[:name]
    name_not = [@wheres[:name_not]]

    name.gsub!(/CNC/i, 'NC') # CNC
    name_not << "NC" if name.match?(NC_WORDS) && !name.match?(/NC/i) # not NC
    name_not << "ブレーキ" if name.include?("プレス") && name.exclude?("ブレーキ") # not プレスブレーキ
    name_not << "セット" if name.include?("プレス") && name.exclude?("セット") # not セットプレス
    name_not << "油圧" if %w[プレス 電動].all? { |w| name.include?(w) } # not 電動プレス

    NORMALIZATION_MAP.each { |v| name.gsub!(Regexp.union(v), "(#{v.join('|')})") } # 漢数字、数字ノーマライズ

    @wheres[:name]     = name
    @wheres[:name_not] = name_not.compact.uniq.join('|')
  end

  private

  # OpenAIクライアントを返す
  def client
    OpenAI::Client.new(log_errors: true, request_timeout: REQUEST_TIMEOUT)
  end
end
