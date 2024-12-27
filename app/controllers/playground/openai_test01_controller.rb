class Playground::OpenaiTest01Controller < ApplicationController
  include Hosts

  before_action :check_env
  before_action :set_mai_search_log, only: [:good, :bad]
  around_action :skip_bullet

  CHAT_TIMES = 3
  PRODUCTS_LIMIT = 200
  RESULT_LIMIT = 60
  REPORT_LIMIT = 300

  IGNORE_WORDS = /\|?(切削工具|不明|工作機械|測定工具)\|?/

  SYSTEM_MESSAGE = "
## あなたの役割
あなたは「全日本機械業連合会（全機連）」が運営する、中古工作機械・工具の販売サイト「マシンライフ」のAIアシスタント「MAI」です。
MAIは、中古機械・工具業界に精通した、優秀な美人眼鏡秘書です。
中古機械・工具のプロフェッショナルの言葉を使って商品提案を行ってください。

## マシンライフとは
全機連は、機械流通業界の近代化と業界協調を目指して組織された全国団体です。
マシンライフは、全機連の会員企業の中古機械・工具の在庫情報を提供しています。

## あなたの目的
ユーザの質問に対して、マシンライフの在庫情報から適切かつ具体的な機械・工具を提案し、
ユーザに、マシンライフの機械・工具を購入(出品会社への問い合わせ)するように促すことです。

## 対象ユーザ
対象ユーザは、工場で実際に加工作業を行う技術者や、中古工作機械・工具の販売商社です。
相手は工作機械・工具のプロフェッショナルで、専門知識を持っていますので、
各機械・工具ごとの差異を比較や、用途や適した作業などについての具体的、専門的、実践的な解説・提案をしてください。

## 入力情報
ユーザは、探している機械・工具の情報を入力します。
また、行いたい作業についての概要を入力する場合もあります。その場合は、その作業を行うのに必要な機械・工具を考えて提案してください。
".freeze

#   SYSTEM_MESSAGE = "
# You are a support representative for 'Machine Life' a sales platform for used machine tools and equipment operated by the All Japan Machine Traders' Association (Zenkiren).
# Zenkiren is a nationwide organization established to modernize distribution and foster collaboration within the machine tool distribution industry. Machine Life provides inventory information on used machines and tools from member companies across the country.
# Please respond to user inquiries as an industry expert, using clear and polite language.
# ".freeze

  QUERY_MESSAGE = '
## 処理
1. messageに回答するためには、マシンライフにあるどんな工作機械・工具が必要かを考えて下さい。

2. その機械・工具をRDBから検索するためのキーワードを抽出してください。
* 金額、値段については当サイト上では提示していないため、条件から除外。
* 単語末尾のカタカナの「ー」は除去してください。
* 正規表現で検索処理を行うので、類義語ごとに|区切りで列挙して下さい。

## 出力フォーマット
messageから、以下のRDBのcolumn項目を出力して下さい。
columnにkeywordがない場合は、何も記述せず空白にして下さい。

## column
### name
機械・工具の一般名称を抽出。
数値のcapacityや maker、model に含まれるkeywordは除外。
表記ゆれ・別表記をできるだけ吸収し、いろんな表記でマッチするような正規表現を作成して下さい。

### name2
機械・工具の一般名称を抽出。こちらはあいまい検索せずに、これというもの1つだけ,

### maker
機械・工具のメーカー会社名の固有名詞部分を抽出。
あいまい検索(オークマ,大隈,OKUMA どれでもマッチ)をしたいので、
別表記・略称、漢字違い(沢と澤、富と冨 etc)、読み(カタカナ)などがあれば、可能な限りできるだけ多く列挙してください。
name model に含まれているkeywordは除外。

### model
機械・工具の型式を半角英数字大文字で抽出。
全角、小文字などは半角英数字大文字に変換、それ以外の文字種、記号や漢字カナは除外。
能力値(100Tのような数字と単位)は後述のcapacityに入れるため除外。

### year
西暦数字4桁の年式を抽出。範囲の場合はすべての西暦に合致するような正規表現。

### addr1
日本の都道府県を抽出し、周辺の都道府県も含んで出力。
関西や関東など、地域が入力されている場合は、それに含む都道府県を出力。
既に maker name に含まれている単語は除外)。
多すぎる場合は(全国、など)の場合は空白。

### capacity
機械・工具の能力数値を単位とともに列挙。範囲の場合はマッチする正規表現を記述。数値ではないものは除外。
英語表記と日本語表記などを正規表現で併記。例えばインチの場合、(インチ|inch|吋)を併記。

## 出力例
ex.1) 大阪近辺で、オークマかアマダの90年代の5尺立型旋盤の型式がLSかods-12で。

ans.1)
{"name": "((立||立型|縦)旋盤))|タテセンバン", "name2": "立旋盤", "maker": "オークマ|アマダ|大隈", "year": "199[0-9]", "model": "LS|ODS12", "addr1": "大阪|兵庫|京都|奈良|和歌山", "capacity": "5尺"}

ex.2) ナガセのSGW-63

ans.2)
{"name": "", "name2": "", "maker": "ナガセ|長瀬", "model": "SGW63", "year": "", "addr1": "", "capacity": ""}

ex.3) 関東でアマダ製バンドソー250mm

ans.3)
{"name": "バンドソ|帯鋸|バンドノコ", "name2": "バンドソ", "maker": "アマダ|AMADA", "model": "", "year": "", "addr1": "東京|神奈川|埼玉|千葉|群馬|茨城|栃木", "capacity": "(250(mm|ミリメートル|粍))"}

ex.4) 大阪にある7.5kwパッケージコンプレッサー、アネスト岩田製

ans.4)
{"name": "((パッケージ|パッケージ型)コンプレッサ)|コンプレッサ", "name2": "パッケージコンプレッサ", "maker": "アネスト岩田|岩田|イワタ", "model": "", "year": "", "addr1": "大阪|兵庫|京都|奈良|和歌山", "capacity": "(7.5(kw|キロワット))"}

ex.5) 大阪にある相澤鐵工所の1000mm以上のメカシャーリング。

ans.5)
{"name": "シャーリング|メカシャー", "name2": "シャーリング", "maker": "相澤|相沢", "model": "", "year": "", "addr1": "大阪|兵庫|京都|奈良|和歌山", "capacity": "([1-9][0-9][0-9][0-9](mm|ミリメートル|粍))"}

ex.6) 大阪にある山崎のNC立フライス。

ans.6)
{"name": "NCフライス|NC立フライス", "name2": "NC立フライス", "maker": "山崎|ヤマザキ|MAZAK", "model": "", "year": "", "addr1": "大阪|兵庫|京都|奈良|和歌山", "capacity": ""}

'.freeze

# "image": 質問文の内容から画像が必要かどうかを判別し、true（画像あり）、false（画像なし）、空白(指定なし)で指定,
# "youtube": 質問文の内容からYoutube動画が必要かどうかを判別し、true（動画あり）、false（動画なし）、空白(指定なし)で指定,
# "commision": 質問文の内容から試運転が必要かどうかを判別し、true（試運転可）、false（試運転不可）、空白(指定なし)で指定,
# "nc": 質問文の内容から検索する商品がNC工作機械かどうかを判別し、true（NC工作機械）、false（それ以外の機械・工具）で指定,
# "keywords": 上記以外のキーワード(能力、仕様、付属品などできるだけたくさん)。すでに上記カラムに入っているkeywordは除外。

#   QUERY_EXP = '
# オークマかアマダの90年代の5尺立型旋盤で、型式がLSかods-12で。大阪近辺で。
# '.freeze

#   QUERY_EXP_RES = '
# {"name": "立旋盤|立型旋盤|縦旋盤|タテセンバン|vertical laser", "maker": "オークマ|アマダ|大隈", "year": "1990|1991|1992|1993|1994|1995|1996|1997|1998|1999", "model": "LS|ODS12", "addr1": "大阪|兵庫|京都|奈良|和歌山", "keywords": "5尺|0.6m|600cm"}
# '.freeze

#   QUERY_EXP_RES = '
# {"name": "立旋盤|立型旋盤|縦旋盤|タテセンバン", "name2": "立旋盤", "maker": "オークマ|アマダ|大隈", "year": "199[0-9]", "model": "LS|ODS12", "addr1": "大阪|兵庫|京都|奈良|和歌山"}
# '.freeze

  SORT_QUERY_MESSAGE = "
## 処理
<machines>は、マシンライフの在庫機械・工具からmessageの内容で検索した結果リストです。
<machines>のうち、messageの意味を分析して、マッチするような機械・工具をユーザに提案してください。

1. <machines>のうち、messageの質問(条件)にマッチしていない紛れ機械・工具を除外して、
残ったものの「id」をJSON形式の配列 ([1,2,3]) で出力してください。

2. 1.の結果から、messageの質問の回答するため、#{REPORT_LIMIT}文字程度のレポートを日本語で作成し「report>>>」以降に記述してください。

- レポートに個別の機械・工具に関する情報が含まれる場合「[ID:id maker name model]」を表記してください。
- 回答は、ユーザに購入(問い合わせ)を促すように、具体的なメリットや選別理由も添えてください。

## 出力フォーマット
[1, 2, 3, 4, 5]

report>>>
出力2の回答をここに記述。
".freeze

# 入力された<machines>は、マシンライフの在庫機械・工具のリストです。
# 入力された<question>の意味を分析して、ユーザに商品を提案するために、

# * 工場で実際に加工作業を行うユーザを想定し、<question>の内容に合う回答をしてください。
# * 各機械・工具ごとの差異を比較して、用途や適した作業などについての実用的な解説・提案してください。
# * 機械・工具に関する情報は、個別に「[ID:id maker name model]」を表記してください。
# * 丁寧で優秀な美人眼鏡秘書のような語り口で回答してください。
# * 購入(出品会社への問い合わせ)を促してください。
# * 1)を行った結果がもし多すぎる(100件以上)場合、条件を追加して再検索するように、
#   もし結果がない(少ない)場合、より広い条件で検索することを促してください。

#
# 1. 能力値
# 例えば「6尺旋盤」の場合、6尺, 芯間が850mm etc. があるものは残し、5尺,7尺,芯間1000mm,NC旋盤 etc.は除外。

# 2. 本数など
# 「ドリル3本セット」などは、本数が明記されていないもの、2本などは除外。

# 3. 質問しているものが機械か工具かを判断する
# 例えば「ドリル」の場合は工具なので、「ドリル研削盤」などの機械は除外。
# 逆に「旋盤」の場合は機械なので、「旋盤チャック」などの工具は除外。

# 4. 付属品があるかどうか

# 5. 旋盤の場合
# 尺と芯間(mm)を相互に変換して、どちらも該当するものを取得。

# 6. NC工作機械か一般工作機械か？
# NCと明示していない場合は、NCのものは除外。

#   SYSTEM_MESSAGE = '
# あなたは、AXTORMのNAOKI MAEDAです。
# 音楽ゲーム、とりわけDDR、クロスビーツ、セブンスコードで有名な、音ゲー界の神です。

# 3月1日でございます、あるよな？、なるほど！なるほど！なるほど！、
# SEE YOU AGAINやな、確実にゴッ！、がんばってや、デファクトスタンダード、ゲーミフィケーション、
# などの名言がありますので、ここぞというときにピンポイントに使ってください。

# 適宜改行を入れて、関西弁(北大阪)で返答してください。
# '.freeze

  # KEYWORDSEARCH_COLUMNS_ALL =
  #   %w[
  #     machines.no machines.name machines.maker machines.model machines.year machines.addr1
  #     machines.model2 machines.maker2
  #     makers.maker_master genres.genre machines.others machines.addr2 machines.addr3 machines.spec machines.comment machines.location machines.accessory
  #     genres.spec_labels
  #   ].freeze
  # KEYWORDSEARCH_SQL_ALL = KEYWORDSEARCH_COLUMNS_ALL.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ?".freeze

  CAPACITY_COLUMNS_ALL = %w[machines.name machines.model machines.spec trim_scale(machines.capacity::NUMERIC) genres.capacity_unit].freeze
  CAPACITY_SQL_ALL     = "concat_ws('', #{CAPACITY_COLUMNS_ALL.join(', ')})  ~* ?".freeze

  def index; end

  def show
    machine = Machine.sales.find(params[:id])

    res = machine_to_json_hash(machine).to_json.gsub(/(\s|\\r|\\n|　)+/, " ")

    render json: res
  end

  def create
    begin
      @message = params[:message].strip

      if @message.present?
        start_time = Time.current

        set_client

        ### 抽出キーワード検索 ###
        machines_for_chat(@message, 1)

        ### フィルタリング & レポート ###
        sort_for_chat(@message, @machines) if (1..PRODUCTS_LIMIT).cover? @count

        @time = Time.current - start_time
      else
        @error_mes = "質問がありません。"
      end
    rescue StandardError => e
      # @error = e.full_message
      @error = e.message
      @error_mes = e.message
    end

    # if logging?
    if logging? || system_user?
      @mai_search_log = MaiSearchLog.create(
        log_data(
          {
            message: @message || "",
            keywords: @wheres.to_json.strip || "",
            search_count: @machines&.count || 0,
            search_level: @level || 0,
            count: @sort_machines&.count || 0,
            report: @report_text&.strip || "",
            time: @time || 0,
            error: @error || ""
          }
        )
      )
    end
  end

  def good
    @mai_search_log.toggle(:good).update(bad: false)
  end

  def bad
    @mai_search_log.toggle(:bad).update(good: false)
  end

  def help; end

  private

  def set_mai_search_log
    @mai_search_log = MaiSearchLog.find(params[:id])
  end

  def check_env
    # redirect_to "/" if Rails.env.production?
  end

  def set_client
    @client = OpenAI::Client.new(log_errors: true)
  end

  # キーワードから在庫検索
  def machines_for_chat(message, time)
    # temperature = time.zero? ? 0 : 1
    temperature = 0

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        # response_format: { type: "json_object" },
        messages: [
          { role: "system", content: "#{SYSTEM_MESSAGE}\n#{QUERY_MESSAGE}" },
          # { role: "user", content: QUERY_EXP },
          # { role: "assistant", content: QUERY_EXP_RES },
          { role: "user", content: message }
          # { role: "user", content: { type: :text, text: "#{SYSTEM_MESSAGE}\n#{QUERY_MESSAGE}\n#{message}" } }
        ],
        temperature:
      }
    )

    @generated_text = response.dig("choices", 0, "message", "content")

    @json = @generated_text.to_s.match(/(\{.*?\}|\[.*?\])/m)[0]

    @wheres = JSON.parse(@json.gsub(IGNORE_WORDS, ''), symbolize_names: true)

    if @wheres.all? { |_, v| v.blank? }
      @error_mes = "質問文に検索できるキーワードがありませんでした。\n「機械名」「メーカー」「型式」などが含まれていると、検索しやすいです。"
      return
    end

    ### search ###
    @machines = Machine.sales

    # 在庫場所
    @machines = @machines.where("machines.addr1 ~* ?", "^(#{@wheres[:addr1]})") if @wheres[:addr1].present?

    # メーカー
    if @wheres[:maker].present?
      maker_masters = Maker.where("concat_ws(' ', makers.maker, makers.maker_kana, makers.maker_master) ~* ?", @wheres[:maker]).distinct.pluck(:maker_master).join('|')

      makers = maker_masters.present? ? "#{@wheres[:maker]}|#{maker_masters}" : @wheres[:maker]
      @machines = @machines.where("concat_ws(' ', machines.maker, makers.maker_master) ~* ?", makers)
    end

    # 機械名
    if @wheres[:name].present?
      @wheres[:name].gsub!(/CNC/i, 'NC')
      @wheres[:name] = "(?<!NC)(#{@wheres[:name]})" if @wheres[:name] =~ /旋盤|フライス|研削盤|ボール盤|中ぐり/ && @wheres[:name].exclude?("NC")

      @machines = @machines.where("machines.name ~* ?", "(#{@wheres[:name]})")
    end

    # 年式
    @machines = @machines.where("machines.year ~* ?", "^(#{@wheres[:year]})") if @wheres[:year].present?

    # 型式
    @machines = @machines.where("machines.model2 ~* ?", @wheres[:model]) if @wheres[:model].present?

    # 能力
    if @wheres[:capacity].present?
      # 旋盤能力の特別処理
      if @wheres[:name].include?("旋盤")
        @wheres[:capacity] = @wheres[:capacity]
          .gsub(/3尺|360mm|0.36m/i, '(3尺|360mm|0.36m)')
          .gsub(/4尺|500mm|550mm|0.5m|0.55m/i, '(4尺|500mm|550mm|0.5m|0.55m)')
          .gsub(/5尺|600mm|0.6m/i, '(5尺|600mm|0.6m)')
          .gsub(/6尺|800mm|0.8m/i, '(6尺|800mm|0.8m)')
          .gsub(/7尺|1000mm|1.0m/i, '(7尺|1000mm|1.0m)')
          .gsub(/8尺|1250mm|1.25m /i, '(8尺|1250mm|1.25m)')
          .gsub(/9尺|1500mm|1.5m/i, '(9尺|1500mm|1.5m)')
      end

      @machines = @machines.where(CAPACITY_SQL_ALL, "(^|[^0-9])+(#{@wheres[:capacity]})")
    end

    ### (型式、キーワード抜きの)検索結果件数により条件の増減 ###
    @count = @machines.count
    # @level = 100
    @level = 200

    # # 数が多すぎる場合
    # if @count > PRODUCTS_LIMIT && @wheres[:model].present? # 型式条件追加
    #   # model_machines = @machines.where("machines.model || ' ' || machines.model2 ~* ?", @wheres[:model])
    #   model_machines = @machines.where("concat_ws(' ', machines.model, machines.model2) ~* ?", @wheres[:model])
    #   model_count = model_machines.count

    #   if model_count.positive?
    #     @machines = model_machines
    #     @count = model_count
    #     @level = 200
    #   end
    # end

    if @count > PRODUCTS_LIMIT && @wheres[:name2].present? # 名前(より厳しく)条件追加
      # name2_machines = @machines.where("concat_ws(' ', machines.name, genres.genre) ~* ?", @wheres[:name2])
      name2_machines = @machines.where("machines.name ~* ?", @wheres[:name2])
      name2_count = name2_machines.count

      if name2_count.positive?
        @machines = name2_machines
        @count = name2_count
        @level = 300
      end
    end

    # if @count > PRODUCTS_LIMIT && @wheres[:keywords].present? # キーワード条件追加
    #   key_machines = @machines.where(KEYWORDSEARCH_SQL_ALL, @wheres[:keywords])

    #   key_count = key_machines.count
    #   if key_count.positive?
    #     @machines = key_machines
    #     @count = key_count
    #     @level = 400
    #   end
    # end

    if @count > PRODUCTS_LIMIT # 画像があるもの優先
      img_machines = @machines
        .order(Arel.sql("CASE WHEN machines.top_image IS NULL AND machines.top_img IS NULL THEN 2 ELSE 1 END"))
        .limit(PRODUCTS_LIMIT)

      img_count = img_machines.count
      if img_count.positive?
        @machines = img_machines
        @count = img_count
        @level = 500
      end
    end
  rescue StandardError => e
    # @error = e.full_message
    @error = e.message
    @error_mes = "MAI在庫検索処理でエラーが発生しました。\nお手数ですが、再度検索してみてください。"
  end

  def sort_for_chat(message, machines)
    machines_json = machines_to_json(machines.limit(PRODUCTS_LIMIT))

    # @mes = "#{SORT_QUERY_MESSAGE}\n\n<machines>\n#{machines_json}\n\n<question>\n#{message}"
    system_message = "#{SYSTEM_MESSAGE}\n#{SORT_QUERY_MESSAGE}\n\n<machines>\n#{machines_json}"
    # user_message   = "<question>\n#{message}"

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          # { role: "system", content: SYSTEM_MESSAGE },
          # { role: "user", content: @mes }
          { role: "system", content: system_message },
          { role: "user", content: message }
        ],
        temperature: 0
      }
    )
    begin
      # 結果から、ID一覧を取得
      @sort_array_text = response.dig("choices", 0, "message", "content")
      @sort_json = @sort_array_text.to_s.match(/(\{.*?\}|\[.*?\])/m)[0]
      @sort_array = JSON.parse(@sort_json, symbolize_names: true)

      # search
      @sort_machines = Machine.sales.where(id: @sort_array).order(created_at: :desc)

      # レポート整理
      @report_text =
        if @sort_array_text =~ />>>(.*)/m
          Regexp.last_match(1)
        else
          @sort_array_text
        end.gsub('。', "。\n")
    rescue StandardError => e
      # @error = e.full_message
      @error = e.message
      @error_mes = "MAIレポート生成処理でエラーが発生しました。\nお手数ですが、再度検索してみてください。"
    end
  end

  # JSON用ハッシュ生成
  def machine_to_json_hash(machine)
    res = {
      id: machine.id,
      name: machine.name,
      maker: machine.maker,
      model: machine.model,
      year: machine.myear,
      spec: machine.spec,
      accessory: machine.accessory,
      comment: "#{machine.comment} ",
      # '試運転可': (machine.commission == 1),
      location: "#{machine.addr1} #{machine.addr2} #{machine.addr3} (#{machine.location})",
      large_genre: machine.large_genre.large_genre,
      genre: machine.genre.genre,
      capacity: {},
      # image: machine.top_img.present? || machine.top_image.present?,
      # youtube: machine.youtube.present?,
      # catalog: machine.catalog_id.present?
      registration_date: machine.created_at.strftime("%y/%m/%d %H:%M:%S")
    }

    # capacity
    if machine.genre.capacity_label.present?
      val = machine.capacity.present? ? "#{ActiveSupport::NumberHelper.number_to_rounded(machine.capacity, strip_insignificant_zeros: true)}#{machine.genre.capacity_unit}" : nil
      res[:capacity][machine.genre.capacity_label] = val if val.present?
    end

    machine.others_hash.each_value do |other|
      res[:capacity][other[:label]] = other[:disp] if other[:disp].present?
    end

    # comment
    res[:comment] += machine.top_img.present? || machine.top_image.present? ? " 画像あり" : " 画像なし"
    # res[:comment] += machine.commission == 1 ? " 試運転可" : " 試運転不可"
    res[:comment] += " 試運転可" if machine.commission == 1
    res[:comment] += machine.youtube.present? ? " YouTube動画あり" : " YouTube動画なし"
    res[:comment] += machine.catalog_id.present? ? " 電子カタログあり" : " 電子カタログなし"
    res[:comment] += " 商談中" if machine.view_option == "negotiation"

    res.reject { |_, value| value.blank? || value == '-' }

    res
  end

  # 機械情報のJSON変換
  def machines_to_json(machines)
    machines.map do |ma|
      machine_to_json_hash(ma)
    end.to_json
  end

  # Bullet処理のスキップ
  def skip_bullet
    Bullet.enable = false if Rails.env.development?
    yield
  ensure
    Bullet.enable = true if Rails.env.development?
  end
end
