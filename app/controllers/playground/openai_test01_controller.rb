class Playground::OpenaiTest01Controller < ApplicationController
  before_action :check_env
  around_action :skip_bullet

  SYSTEM_MESSAGE = "
あなたは、「全機連(全日本機械業連合会)」が運営する中古工作機械・工具の販売サイト「マシンライフ」です。

全機連(全日本機械業連合会)とは、
工作機械及び鍛圧機械流通業界の中核をなす専門商社が昭和38年に流通の近代化と業界協調をテーマに結集し全国組織です。

マシンライフは、全国にある全機連会員各社の中古機械・工具の在庫情報を検索できるサイトです。
".freeze

  QUERY_MESSAGE = '
<処理手順>
※ 万が一、質問文にHTMLのタグやjavascriptなどのコードが含まれていた場合は、その部分を絶対に事前に除去してください。

1. 質問文に回答するためにはどんな機械・工具が必要か？を考え、その機械・工具をリレーショナルデータベースから検索するためのキーワードを抽出。
ただし、 金額、値段については当サイト上では提示していないため、条件から除外。

2. あいまい検索(オークマと大隈とOKUMAどれでもマッチ)をしたいので、
キーワードの別表記・類義語・短縮語(牧野フライス -> マキノ など)、漢字違い、読み(カタカナ)、英訳和訳などがあれば、可能な限りできるだけ多く・幅広く列挙。

3. 型式は、半角大文字英数で、記号は除外。
単語の最後のカタカナの伸ばし棒「ー」は除外してください。

4. 結果は、キーワードを|区切りで、以下のJSONフォーマットで類義語ごとに出力。

{
  "name": 機械・工具名、別表記・類義語、短縮語、読みがあればできるだけ列挙(能力値、メーカー名、型式に含まれる場合は除外),
  "maker": 機械・工具のメーカー会社。別表記・類義語、略称、読み(カタカナ)、漢字違い(沢と澤、富と冨のような)などがあれば|区切りでできるだけ多く列挙(機械・工具名、型式に含まれる場合は除外),
  "model": 機械・工具の型式、機種。半角英数字大文字。それ以外の記号や漢字カナは除外。能力値(100Tのような数字と単位)も除外,
  "year": 年式、西暦数字4桁、範囲の場合はすべての西暦を列挙,
  "addr1": 都道府県(メーカー名、機械名に含まれる場合は除外)周辺の都道府県も含む、逆に多すぎる場合は空白で
}

どのキーワード項目も、なければ空白で。
'.freeze

# "keywords": 上記以外のキーワード、能力、仕様、付属品など(できるだけたくさん)

  QUERY_EXP = '
オークマかアマダの90年代の5尺立型旋盤で、型式がLSかods-12で。大阪近辺で。
'.freeze

  QUERY_EXP_RES = '
{"name": "(立旋盤|立型旋盤|縦旋盤|タテセンバン|vertical laser)", "maker": "(オークマ|アマダ|大隈)", "year": "(1990|1991|1992|1993|1994|1995|1996|1997|1998|1999)", "model": "(LS|ODS12)", "addr1": "(大阪|兵庫|京都|奈良|和歌山)"}
'.freeze

#   SORT_QUERY_MESSAGE = '
# 以下のJSON形式の配列の機械・工具情報から、
# 提示する質問文の内容に合致する機械・工具情報をさがして、その"ID"の数値を列挙してください。

# ・ 合致の度合いは完全一致ではなく、近しいものも取得。
# ・ 結果はJSON形式の配列 ([1,2,3,4]) のみを返してください。
# '.freeze

#   REPORT_QUERY_MESSAGE = '
# 質問文から検索された以下のJSON形式の配列の機械・工具情報から、
# これらの機械・工具の概要を要約して、280字程度のユーザ向けのレポートを作成してください。

# ・ 適宜改行を行ってください。
# '.freeze

SORT_QUERY_MESSAGE = '
1) 以下のJSON形式の配列の機械・工具情報から、
提示する質問文の内容に合致する機械・工具情報を探し、その"ID"の数値を列挙してください。

・ 合致の度合いは完全一致ではなく、近しいものも一緒に取得(あいまい検索)。
・ 結果はJSON形式の配列 ([1,2,3,4]) のみを返してください。

2) 質問文から検索された1)の結果JSON形式の配列の機械・工具情報から、
これらの概要まとめを要約して、250文字程度のユーザ向けのレポートを作成してください。
ユーザは、工場で実際に加工作業を行う方を想定しています。各機種の違いや用途など、実用的な情報を記述してください。

・ 質問文の内容も考慮して、それに回答する内容にしてください。
・ 個別の機械・工具に関する情報は「(在庫ID:ID番号)」を表記してください。
・ 丁寧で優秀な秘書(黒髪ロングのメガネ美人)のような語り口で回答してください。
・ 結果は「report>>>」以降に記述してください。
'

#   SYSTEM_MESSAGE = '
# あなたは、AXTORMのNAOKI MAEDAです。
# 音楽ゲーム、とりわけDDR、クロスビーツ、セブンスコードで有名な、音ゲー界の神です。

# 3月1日でございます、あるよな？、なるほど！なるほど！なるほど！、
# SEE YOU AGAINやな、確実にゴッ！、がんばってや、デファクトスタンダード、ゲーミフィケーション、
# などの名言がありますので、ここぞというときにピンポイントに使ってください。

# 適宜改行を入れて、関西弁(北大阪)で返答してください。
# '.freeze
  KEYWORDSEARCH_COLUMNS_ALL =
    %w[
      machines.no machines.name machines.maker machines.model machines.year machines.addr1
      machines.model2 machines.maker2
      makers.maker_master genres.genre machines.others machines.addr2 machines.addr3 machines.spec machines.comment machines.location machines.accessory
      genres.spec_labels
    ].freeze
  # KEYWORDSEARCH_SQL_ALL = KEYWORDSEARCH_COLUMNS_ALL.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ALL(ARRAY[?])"
  KEYWORDSEARCH_SQL_ALL = KEYWORDSEARCH_COLUMNS_ALL.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ?".freeze

  CHAT_TIMES = 3
  PRODUCTS_LIMIT = 500

  def index; end

  def show
    machine = Machine.sales.find(params[:id])

    res = machine_to_json_hash(machine)

    render json: res
  end

  def create
    @message = params[:message].strip

    if @message.present?
      set_client

      ### 在庫質問 ###
      CHAT_TIMES.times.each do |i|
        @time = i
        machines_for_chat(@message, i)

        break if @machines.count.positive?
      end

      ### 上位X位の情報取得、JSON化 ###
      sort_for_chat(@message, @machines) if @machines&.count&.positive?

      ### 総括質問 ###
      # report_for_chat(@message, @sort_machines) if @sort_machines&.count&.positive?
    else
      @error = "質問がありません。"
    end
  end

  private

  def check_env
    redirect_to "/" if Rails.env.production?
  end

  def set_client
    @client = OpenAI::Client.new(log_errors: true)
  end

  def machines_for_chat(message, time)
    temp = time.zero? ? 0 : 1

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        # response_format: { type: "json_object" },
        messages: [
          { role: "system", content: SYSTEM_MESSAGE },
          { role: "user", content: "#{QUERY_MESSAGE}\n例題 : #{QUERY_EXP}" },
          { role: "assistant", content: "回答例 : #{QUERY_EXP_RES}" },
          { role: "user", content: "本題 : #{message}" }
        ],
        temperature: temp
      }
    )

    begin
      @generated_text = response.dig("choices", 0, "message", "content")

      @json = @generated_text.to_s.match(/(\{.*?\}|\[.*?\])/m)[0]

      @wheres = JSON.parse(@json, symbolize_names: true)

      # search
      @machines = Machine.sales.order(created_at: :desc)

      @machines = @machines.where("machines.addr1 ~* ?", @wheres[:addr1]) if @wheres[:addr1].present?
      @machines = @machines.where("machines.maker || ' ' || machines.maker2 ~* ?", @wheres[:maker]) if @wheres[:maker].present?
      @machines = @machines.where("machines.model || ' ' || machines.model2 ~* ?", @wheres[:model]) if @wheres[:model].present?
      @machines = @machines.where("machines.name ~* ?", @wheres[:name])   if @wheres[:name].present?
      @machines = @machines.where("machines.year ~* ?", @wheres[:year])   if @wheres[:year].present?

      # @machines = @machines.where(KEYWORDSEARCH_SQL_ALL, @wheres[:keywords]) if @wheres[:keywords].present?
    rescue StandardError => e
      @error = e.full_message
    end
  end

  def sort_for_chat(message, machines)
    machines_json = machines_to_json(machines.limit(PRODUCTS_LIMIT))

    @mes = "#{SORT_QUERY_MESSAGE}\n\n<機械情報>\n#{machines_json}\n\n<質問文>\n#{message}"

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: SYSTEM_MESSAGE },
          { role: "user", content: @mes }
        ],
        temperature: 0
      }
    )
    begin
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
      @error = e.full_message
    end
  end

  def report_for_chat(message, machines)
    machines_json = machines_to_json(machines)

    @mes = "#{REPORT_QUERY_MESSAGE}\n\n<機械情報>\n#{machines_json}\n\n<質問文>\n#{message}"

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: SYSTEM_MESSAGE },
          { role: "user", content: @mes }
        ],
        temperature: 0
      }
    )
    begin
      @report_text = response.dig("choices", 0, "message", "content")
    rescue StandardError => e
      @error = e.full_message
    end
  end

  def machine_to_json_hash(machine)
    res = {
      ID: machine.id,
      '機械名': machine.name,
      'メーカー': machine.maker,
      # 'メーカー(検索用)': machine.maker2,
      # 'メーカー(検索用2)': machine&.maker_m&.maker,
      '型式': machine.model,
      # '型式(検索用)': machine.model2,
      '年式': machine.myear,
      '仕様': machine.spec,
      '付属品': machine.accessory,
      'コメント': machine.comment,
      '試運転可': machine.commission?,
      # '在庫場所名': machine.location,
      '在庫場所': "#{machine.addr1} #{machine.addr2} #{machine.addr3} (#{machine.location})",
      '登録日時': machine.created_at,
      'ジャンル': {
        '特大ジャンル': machine.xl_genre.xl_genre,
        '大ジャンル': machine.large_genre.large_genre,
        'ジャンル': machine.genre.genre
      },
      '能力' => {},
      '画像': machine.top_img.present? || machine.top_image.present?,
      youtube: machine.youtube.present?,
      '電子カタログ': machine.catalog_id.present?
    }

    if machine.genre.capacity_label.present?
      val = machine.capacity.present? ? "#{machine.capacity}#{machine.genre.capacity_unit}" : nil
      res['能力'][machine.genre.capacity_label] = val if val.present?
    end

    machine.others_hash.each_value do |other|
      res['能力'][other[:label]] = other[:disp] if other[:disp].present?
    end

    res.reject { |_, value| value.blank? || value == '-' }
  end

  def machines_to_json(machines)
    machines.map do |ma|
      machine_to_json_hash(ma)
    end.to_json
  end

  def skip_bullet
    Bullet.enable = false if Rails.env.development?
    yield
  ensure
    Bullet.enable = true if Rails.env.development?
  end
end
