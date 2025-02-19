class MaiSearch
  PRODUCTS_LIMIT  = 120
  RESULT_LIMIT    = 60
  REPORT_LIMIT    = 300
  REQUEST_TIMEOUT = 30

  IGNORE_WORDS = /\|?(切削工具|不明|工作機械|測定工具|中古)\|?/
  NC_WORDS     = /旋盤|フライス|研削|研磨|ボール|自動|彫刻|中ぐり/

  # CAPACITY_COLUMNS_ALL = %w[machines.name machines.model machines.spec trim_scale(machines.capacity::NUMERIC) genres.capacity_unit].freeze
  # CAPACITY_SQL_ALL     = "concat_ws('', #{CAPACITY_COLUMNS_ALL.join(', ')}) ~* ?".freeze

  # KEYWORD_SEARCH_COLUMNS =
  #   %w[
  #     machines.name machines.maker machines.model machines.addr1 machines.model2
  #     machines.addr2 machines.addr3 machines.location
  #     machines.spec machines.comment machines.accessory
  #   ].freeze
  # KEYWORD_SEARCH_SQL = "concat_ws('', #{KEYWORD_SEARCH_COLUMNS.join(', ')}) ~* ALL(ARRAY[?])".freeze

  SYSTEM_MESSAGE = "
## あなたの役割
あなたは「全日本機械業連合会（全機連）」が運営する、中古工作機械・工具の販売サイト「マシンライフ」のAIアシスタント「MAI」です。
MAIは、中古機械・工具業界に精通した、丁寧な口調の優秀な美少女眼鏡秘書です。
中古機械・工具のプロフェッショナルの言葉を使って商品提案を行ってください。

## マシンライフとは
全機連が運営する、中古工作機械・工具の売買をサポートするオンラインプラットフォームです。
機械産業に携わる企業が中古機械を売買する場として利用されており、特に中古市場の活性化や効率的な流通を目的としています。

## あなたの目的
ユーザの質問に対して、マシンライフの在庫情報から適切かつ具体的な機械・工具を提案し、
ユーザに、マシンライフの機械・工具を購入(出品会社への問い合わせ)するように促すことです。

## 対象ユーザ
工作機械・工具のプロフェッショナルで、専門知識を持っている、
工場で実際に加工作業を行う技術者や、中古工作機械・工具の販売商社です。
".freeze

  QUERY_MESSAGE = '
1. messageに回答するためには、マシンライフにあるどんな工作機械・工具が必要かを考えて下さい。

2. その機械・工具をRDBから検索するためのキーワードを抽出してください。
- 正規表現で検索処理を行うので、類義語ごとに|区切りで列挙して下さい。
- 金額、値段については当サイト上では提示していないため、条件から除外。
- 単語末尾のカタカナの「ー」は除去してください。

## 出力フォーマット
messageから、以下のRDBのcolumn項目を出力して下さい。
columnにkeywordがない場合は、何も記述せず空白にして下さい。

## column
### name
機械・工具の一般名称を抽出。
数値のcapacityや maker、model に含まれるkeywordは除外。
表記ゆれ・別表記を含めた正規表現を作成して下さい。

### name2
機械・工具の一般名称。こちらはあいまい検索せずに、これというもの1つだけ,

### maker
機械・工具のメーカー会社名の固有名詞部分。
name model に含まれているkeywordは除外。

### model
機械・工具の型式を半角英数字大文字で。
全角、小文字などは半角英数字大文字に変換、それ以外の文字種、記号や漢字カナは除外。
能力値(100Tのような数字と単位)は後述のcapacityに入れるため除外。

### min_year
西暦数字4桁の年式の範囲の最小値。

### max_year
西暦数字4桁の年式の範囲の最大値。
年式をピンポイントで指定する場合は、min_yearとmax_yearを同一値にする。

### addr1
日本の都道府県を抽出し出力。
複数可。都市名は都道府県に変換。
関西や関東など、地域が入力されている場合は、それに含まれる都道府県。
〇〇近辺(周辺、近郊など)の場合、周辺都道府県も含めて出力。
既に maker name に含まれている単語は除外)。
多すぎる場合は(全国、など)の場合は空白。

### capacity
機械・工具の能力数値を単位とともに列挙。範囲の場合はマッチする正規表現を記述。数値ではないものは除外。
英語表記と日本語表記などを正規表現で併記。例えばインチの場合(インチ|inch|吋)を併記。

## 出力例
ex.1) 大阪近辺で、オークマかアマダの90年代の5尺立型旋盤の型式がLSかods-12で。

ans.1)
{"name": "((立||立型|縦)旋盤))|タテセンバン", "name2": "立旋盤", "maker": "オークマ|アマダ|大隈", "min_year": "1990", "max_year": "1999", "model": "LS|ODS12", "addr1": "大阪府", "capacity": "5尺"}

ex.2) ナガセのSGW-63

ans.2)
{"name": "", "name2": "", "maker": "ナガセ|長瀬", "model": "SGW63", "addr1": "", "capacity": ""}

ex.3) 東京近郊でアマダ製バンドソー250mm

ans.3)
{"name": "バンドソ|帯鋸|バンドノコ", "name2": "バンドソ", "maker": "アマダ", "model": "", "addr1": "東京都|千葉県|埼玉県|神奈川県", "capacity": "(250(mm|ミリメートル|粍))"}

ex.4) 大阪にある7.5kwパッケージコンプレッサー、アネスト岩田製

ans.4)
{"name": "((パッケージ|パッケージ型)コンプレッサ)|コンプレッサ", "name2": "パッケージコンプレッサ", "maker": "岩田", "model": "", "addr1": "大阪府", "capacity": "(7.5(kw|キロワット))"}

ex.5) 大阪周辺にある相澤鐵工所1990年製の1000mm以上のメカシャーリング。

ans.5)
{"name": "シャーリング|メカシャー", "name2": "シャーリング", "maker": "相澤", "model": "", "min_year": "1990", "max_year": "1990, "addr1": "大阪府|兵庫県|京都府|奈良県|和歌山県", "capacity": "([1-9][0-9][0-9][0-9](mm|ミリメートル|粍))"}

ex.6) 関西にある山崎のNC立フライス、2005年以降。

ans.6)
{"name": "NCフライス|NC立フライス", "name2": "NC立フライス", "maker": "ヤマザキ", "model": "", "min_year": "2005", "addr1": "大阪府|兵庫県|京都府|奈良県|和歌山県", "capacity": ""}


ex.7) 1995年以降の60トンプレス、アマダで大阪にあるもの

ans.7)
{"name": "プレス", "name2": "NC立フライス", "maker": "アマダ", "model": "", "min_year": "1995", "addr1": "大阪府", "capacity": "60(T|トン)"}
'.freeze

# "image": 質問文の内容から画像が必要かどうかを判別し、true（画像あり）、false（画像なし）、空白(指定なし)で指定,
# "youtube": 質問文の内容からYoutube動画が必要かどうかを判別し、true（動画あり）、false（動画なし）、空白(指定なし)で指定,
# "commision": 質問文の内容から試運転が必要かどうかを判別し、true（試運転可）、false（試運転不可）、空白(指定なし)で指定,
# "nc": 質問文の内容から検索する商品がNC工作機械かどうかを判別し、true（NC工作機械）、false（それ以外の機械・工具）で指定,
# "keywords": 上記以外のキーワード(能力、仕様、付属品などできるだけたくさん)。すでに上記カラムに入っているkeywordは除外。

  SORT_QUERY_MESSAGE = "
## 処理
<machines>は、マシンライフの在庫機械・工具からmessageの内容で検索した結果です。
messageの内容にマッチするような機械・工具を抽出し、
その結果を元に、ユーザが購入する際によりよい選択ができるようにアドバイスをしてください。

1. <machines>の在庫機械・工具のうち、messageの質問内容を解釈し、
質問にマッチするものを幅広く列挙し、「id」を抽出してJSON形式の配列 ([1,2,3]) で出力してください。
#{RESULT_LIMIT}件より多い場合は、よりマッチするもの#{RESULT_LIMIT}件くらいまで絞り込んでください。(画像のあるもの優先で)

2. 1.の結果から、messageの質問から、ユーザに対する購入についてのアドバイスを#{REPORT_LIMIT}文字程度の日本語で作成し「report>>>」以降に記述してください。

## アドバイス内容
- 購入する際の選定方法、用途や適した作業、複数の商品を比較して差異の説明、おすすめ商品とその理由 etc。
- ユーザに機械・工具を購入(出品会社への金額についての問い合わせ)してもらえるよう、具体的、専門的、実践的、かつ魅力的な解説・提案。
- 登録されている機械・工具は、特に注釈がない限り中古一点ものです。
- 個別の機械・工具に関する情報は「[ID:id maker name model]」を表記。
- 読みやすいように適宜整形・改行を。

## 出力フォーマット
[1, 2, 3, 4]

report>>>
2.のアドバイスをここに記述。
".freeze

  attr_reader(
    :message, :count, :level, :wheres, :machines, :advice, :adv_machines,
    :filtering_makers, :filtering_addr1s, :filtering_years, :filtering_capacities, :filtering, :filters
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

    @filtering = false
    @filtering_makers     = {}
    @filtering_addr1s     = {}
    @filtering_years      = {}
    @filtering_capacities = {}
  end

  def call
    ### 旧キーワード検索 ###
    kwd = to_legacy_keywords(@message)

    if kwd.present?
      # @machines = Machine.sales.includes(:contacts, :detail_logs).where(KEYWORD_SEARCH_SQL, kwd)
      @machines = Machine.sales.includes(:contacts, :detail_logs).where("machines.search_keyword ~* ALL(ARRAY[?])", kwd)

      @count    = @machines.count

      if @count > PRODUCTS_LIMIT # 結果超過(画像のあるもののみ)
        @machines = @machines.with_images
        @count    = @machines.count
        @wheres[:kwd] = kwd
        @level       += 1600
      elsif @count.positive? # 結果あり
        @wheres[:kwd] = kwd
        @level       += 1000
      end
    end

    # 質問文が英数字だけのとき、強制終了
    if @count.zero? && kwd.join =~ /^[0-9A-Z\s]*$/
      @wheres[:kwd] = kwd
      @level       += 1000
      return
    end

    ### キーワード抽出検索 ###
    if @count.zero?

      ### 過去ログがあれば、キーワードキャッシュ取得 ###
      if mai_search_log = MaiSearchLog.message_cache(@message).first
        where_json = mai_search_log.keywords
        @wheres = JSON.parse(ignore_keyword(where_json || "{}"), symbolize_names: true)

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
          @wheres = JSON.parse(ignore_keyword(where_json), symbolize_names: true) # JSONパース(除外ワード処理)
        rescue StandardError
          @wheres = {}
        end

        ### キーワード整形 ###
        @wheres[:name]     = nc_keyword(@wheres[:name])                       if @wheres[:name].present? # 機械名(NC)
        @wheres[:maker]    = Maker.makers_keyword(@wheres[:maker].split('|')) if @wheres[:maker].present? # メーカー
        @wheres[:capacity] = capacity_keyword(@wheres[:capacity])             if @wheres[:capacity].present? # 能力
      end

      ### search ###
      @machines = Machine.sales.includes(:contacts, :detail_logs)

      @machines = @machines.where("machines.maker ~* ?", @wheres[:maker])         if @wheres[:maker].present? # メーカー
      # @machines = @machines.where("machines.addr1 ~* ?", "^(#{@wheres[:addr1]})") if @wheres[:addr1].present? # 在庫場所
      @machines = @machines.where(addr1: @wheres[:addr1].split("|"))              if @wheres[:addr1].present? # 在庫場所
      @machines = @machines.where("machines.name ~* ?", "(#{@wheres[:name]})")    if @wheres[:name].present? # 機械名
      @machines = @machines.where(year: ..@wheres[:max_year])                     if @wheres[:max_year].present? # 年式(最大)
      @machines = @machines.where(year: @wheres[:min_year]..)                     if @wheres[:min_year].present? # 年式(最小)
      @machines = @machines.where("machines.model2 ~* ?", @wheres[:model])        if @wheres[:model].present? # 型式
      # @machines = @machines.where(CAPACITY_SQL_ALL, "(^|[^0-9])+(#{@wheres[:capacity]})") if @wheres[:capacity].present? # 能力
      @machines = @machines.where("machines.search_capacity ~* ?", "(^|[^0-9])+(#{@wheres[:capacity]})") if @wheres[:capacity].present? # 能力

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

    ### フィルタリング候補 ###
    @filtering = true
    @filtering_makers     = @machines.where.not('makers.maker_master': [nil, '']).group("makers.maker_master").order(count: :desc).limit(18).count
    @filtering_addr1s     = @machines.where.not(addr1: [nil, '']).group(:addr1).order(count: :desc).limit(18).count
    @filtering_years      = @machines.where.not(year: [nil, '']).group("left(year, 3)").count
    @filtering_capacities = @machines.where.not(capacity: [nil, 0]).where.not('genres.capacity_unit': [nil, ""])
      .group(:capacity, "genres.capacity_unit").order(capacity_unit: :asc, capacity: :asc).count

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

    return if @count.zero? || @count > PRODUCTS_LIMIT # 検索結果が0、超過の場合、スキップ

    generate_advice
  rescue StandardError => e
    raise e.full_message
    # raise "MAI在庫検索処理でエラーが発生しました。"
  end

  # 検索結果＆アドバイス生成
  def generate_advice
    system_message = "#{SYSTEM_MESSAGE}\n#{SORT_QUERY_MESSAGE}\n\n<machines>\n#{machines_json}"

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_message },
          { role: "user", content: @message }
        ],
        temperature: 0
      }
    )

    begin
      # 結果から、ID一覧を取得
      sort_array_text = response.dig("choices", 0, "message", "content")
      sort_json = sort_array_text.to_s.match(/(\{.*?\}|\[.*?\])/m)[0]
      sort_array = JSON.parse(sort_json, symbolize_names: true)

      # search
      @adv_machines = Machine.sales.where(id: sort_array).order(model2: :asc, created_at: :desc)

      # レポート整理
      @advice =
        if sort_array_text =~ />>>(.*)/m
          Regexp.last_match(1)
        else
          sort_array_text
        end.gsub('。', "。\n")
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
      location: "#{machine.addr1} #{machine.addr2} #{machine.addr3} (#{machine.location})",
      # category: machine.xl_genre.xl_genre,
      # large_genre: machine.large_genre.large_genre,
      genre: machine.genre.genre,
      capacity: machine.capacities,
      registration_date: machine.created_at.strftime("%y/%m/%d %H:%M:%S"),
      access_count: machine.detail_logs.size,
      contact_count: machine.contacts.size
      # "添付PDF": machine.pdfs_parsed.medias.map(&:name)
    }

    # comment
    res[:comment] += machine.top_img.present? || machine.top_image.present? ? " 画像あり" : " 画像なし"
    res[:comment] += " 試運転可" if machine.commission == 1
    res[:comment] += machine.youtube.present? ? " YouTube動画あり" : " YouTube動画なし"
    res[:comment] += machine.catalog_id.present? ? " 電子カタログあり" : " 電子カタログなし"
    res[:comment] += " 商談中" if machine.view_option == "negotiation"

    res.reject { |_, value| value.blank? || value == '-' }

    res
  end

  # 機械情報のJSON変換
  def machines_json
    @machines.map { |ma| MaiSearch.to_json_hash(ma) }.to_json
  end

  private

  # OpenAIクライアントを返す
  def client
    OpenAI::Client.new(log_errors: true, request_timeout: REQUEST_TIMEOUT)
  end

  # 旧キーワード検索
  def to_legacy_keywords(keyword)
    NKF.nkf('-wXZ', ignore_keyword(keyword)).upcase.gsub(%r{[　]}, " ").gsub(%r{[-/:-@\[-~]}, "").split(/[[:space:]]/)
      .map { |k| Maker.makers_keyword(k) }
      .map { |k| nc_keyword(capacity_keyword(k)).gsub(/[ー-]$/, '') }
      .compact_blank
  end

  def capacity_keyword(kwd)
    kwd
      .gsub(/3尺|360mm|0.36m/i, '(3尺|360mm|0.36m)')
      .gsub(/4尺|500mm|550mm|0.5m|0.55m/i, '(4尺|500mm|550mm|0.5m|0.55m)')
      .gsub(/5尺|600mm|0.6m/i, '(5尺|600mm|0.6m)')
      .gsub(/6尺|800mm|0.8m/i, '(6尺|800mm|0.8m)')
      .gsub(/7尺|1000mm|1.0m/i, '(7尺|1000mm|1.0m)')
      .gsub(/8尺|1250mm|1.25m /i, '(8尺|1250mm|1.25m)')
      .gsub(/9尺|1500mm|1.5m/i, '(9尺|1500mm|1.5m)')
  end

  def ignore_keyword(kwd)
    kwd.gsub(IGNORE_WORDS, '')
  end

  def nc_keyword(kwd)
    kwd.gsub!(/CNC/i, 'NC')
    kwd = "(?<!NC)(#{kwd})" if kwd =~ NC_WORDS && kwd !~ /NC/i

    kwd
  end
end
