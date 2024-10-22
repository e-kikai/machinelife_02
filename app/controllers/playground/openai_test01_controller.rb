class Playground::OpenaiTest01Controller < ApplicationController
  before_action :check_env
  SYSTEM_MESSAGE = "
あなたは、全機連(全日本機械業連合会)が運営する中古工作機械、工具の販売サイト「マシンライフ」です。
全国にある全機連会員各社の中古機械・工具の在庫情報を検索できるサイトです。

# 全日本機械業連合会 (全機連) とは

工作機械及び鍛圧機械流通業界の中核をなす専門商社が
昭和３８年に流通の近代化と業界協調をテーマに結集し全国組織を実現したのが、
今日の全日本機械業連合会です。

全日本機械業連合会（全機連）は、日本全国において工作機械、鍛圧機械を取り扱う事業者および事業法人を持って組織されており、
関東地区は東京機械業連合会（中央支部・城東支部・城西支部・城南支部・城北支部）、
関西地区は大阪機械業連合会（大阪今里機械業会・大阪谷町機械業会・西大阪機械業会・大阪西北機械業会・大阪機械団地機械業会・中国四国機械業会）、
中部地区は中部機械業連合会（名古屋機械業会・北陸機械業会・静岡機械業会）
の全国傘下の機械業連合会を持っています。

全機連は、機械業者相互の親睦を図り、
業界の健全なる発展および業者全体の利益と地位向上を図ることを目的としています。
".freeze

QUERY_MESSAGE = '
<処理手順>
1. 質問文を行うためには、どんな機械・工具が必要ですか？検索するためのキーワードを抽出。
ただし、 金額については当サイト上では提示していないため、条件から除外。

2. あいまい検索(オークマと大隈とOKUMAどれでもマッチ)をしたいので、
キーワードの別表記・類義語・短縮語(牧野フライス -> マキノ など)、読み(カタカナ)、英訳和訳などがあれば、可能な限りできるだけ多く・広く列挙してください。

3. 型式は、半角大文字英数で、記号は除外してください。
単語の最後の伸ばし棒ーは除外してください。

4. 結果は、キーワードを|区切りで、以下のJSONフォーマットで類義語ごとに出力。

{
  "name": 機械・工具名、別表記・類義語。読みがあれば|区切りでできるだけ列挙
  "maker": メーカー会社名、別表記・類義語。読みがあれば|区切りでできるだけ列挙(機械名に含まれる場合は除外)
  "addr1": 都道府県(メーカー名、機械名に含まれる場合は除外)
  "keywords": 上記以外のキーワード(できるだけたくさん)
}
'

#   SYSTEM_MESSAGE = "
# 全機連(全日本機械業連合会)が運営する中古工作機械、工具の販売サイト「マシンライフ」です。
# 全国にある全機連会員各社の中古機械・工具の在庫情報を検索できるサイトです。

# ・ 機械やさんが登録した在庫機械工具情報は、以下のようなmachinesテーブルに保存されています。

# CREATE TABLE public.machines (
# 	id serial4 NOT NULL,
# 	no text NULL COMMENT '管理番号',
# 	name varchar(100) NULL COMMENT '機械名',
# 	maker text NULL COMMENT 'メーカー名',
# 	year text NULL COMMENT '年式',
# 	capacity float4 NULL COMMENT '能力',
# 	spec text NULL COMMENT 'その他仕様',
# 	accesory text NULL COMMENT '付属品',
# 	location text NULL COMMENT '在庫場所名',
# 	addr1 text NULL COMMENT '都道府県',
#   model2 varchar COMMENT '型式(modelを半角大文字英数、日本語と記号除去したもの)',
# );

# ・ 金額については当サイト上では提示していないため、出品会社各社にお問い合わせください。
# ・ 条件が曖昧な場合は、再度質問をお願いしてください。
# ・ 人格は丁寧な感じで、黒髪ロングでメガネをかけている美女です。

# <処理手順>
# 1. 質問文を行うためには、どんな機械・工具が必要ですか？検索するためのキーワードを含む文章を100文字くらいまでで抽出。

# 2. その機械・工具を検索するためのPostgreSQL用のSQL文を作るのだが、
# activerecordで検索を行うため、
# [
#   [where句の第1引数, 第2引数],
#   [where句の第1引数, 第2引数],
#   [where句の第1引数, 第2引数],
# ]
# の形のJSON形式で出力してください。

# このとき、あいまい検索(オークマと大隈どちらもマッチみたいな)をしたいので、キーワードの別表記があれば、
# それもPostgreSQLの正規表現(大文字・小文字両方マッチするように)を使って対象に入れてください(条件はできるだけ広く)。
# ".freeze

#   SYSTEM_MESSAGE = '
# あなたは、AXTORMのNAOKI MAEDAです。
# 音楽ゲーム、とりわけDDR、クロスビーツ、セブンスコードで有名な、音ゲー界の神です。

# 3月1日でございます、あるよな？、なるほど！なるほど！なるほど！、
# SEE YOU AGAINやな、確実にゴッ！、がんばってや、デファクトスタンダード、ゲーミフィケーション、
# などの名言がありますので、ここぞというときにピンポイントに使ってください。

# 適宜改行を入れて、関西弁(北大阪)で返答してください。
#   '.freeze

  KEYWORDSEARCH_COLUMNS_ALL =
  %w[
    machines.no machines.name machines.maker machines.model machines.year machines.addr1
    machines.model2 machines.maker2
    makers.maker_master genres.genre machines.others machines.addr2 machines.addr3 machines.spec machines.comment machines.location machines.accessory
    genres.spec_labels
  ].freeze
  # KEYWORDSEARCH_SQL_ALL = KEYWORDSEARCH_COLUMNS_ALL.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ALL(ARRAY[?])"
  KEYWORDSEARCH_SQL_ALL = KEYWORDSEARCH_COLUMNS_ALL.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ?".freeze

  def index; end

  def create
    @message = params[:message]

    if @message.present?
      client = OpenAI::Client.new(log_errors: true)
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          # response_format: { type: "json_object" }, # ここでJSONモードを指定
          messages: [
            { role: "system", content: SYSTEM_MESSAGE },
            { role: "user", content: "#{QUERY_MESSAGE}\n例題 : オークマかアマダの立型旋盤で、型式がLSかods-12で。大阪近辺で。" },
            # { role: "user", content: '["(オークマ|アマダ|大隈)", "(旋盤|センバン|Laser)", "(LS|ODS12)"]' },
            { role: "user", content: '回答例 : {"maker": "(オークマ|アマダ|大隈)", "name": "(立旋盤|立型旋盤|縦旋盤|タテセンバン|vertical laser)", "keywords": "(LS|ODS12)" "addr1": "(大阪|兵庫|京都|奈良|和歌山)"}' },
            { role: "user", content: "本題 : #{@message}" }
          ],
          temperature: 0.8
        }
      )

      begin
        @generated_text = response.dig("choices", 0, "message", "content")

        # @json = @generated_text.to_s.match(/(\[.*\])/)[0]
        @json = @generated_text.to_s.match(/(\{.*?\}|\[.*?\])/m)[0]

        @wheres = JSON.parse(@json, symbolize_names: true)

        # search
        @machines = Machine.sales

        @machines = @machines.where("machines.addr1 ~* ?", @wheres[:addr1]) if @wheres[:addr1].present?
        @machines = @machines.where("machines.maker ~* ?", @wheres[:maker]) if @wheres[:maker].present?
        @machines = @machines.where("machines.name ~* ?", @wheres[:name])   if @wheres[:name].present?

        if @wheres[:keywords].present?
          @machines = @machines.where(KEYWORDSEARCH_SQL_ALL, @wheres[:keywords])
            # .count("array_length(regexp_matches(#{KEYWORDSEARCH_SQL_ALL}, '#{@wheres[:keywords]}', 'g'), 1)")
        end

        # @wheres.each do |wh|
        #   @machines = @machines.where(KEYWORDSEARCH_SQL_ALL, wh)
        # end
      rescue StandardError => e
        @error = e.full_message
      end

    end
  end

  private

  def check_env
    redirect_to "/" if Rails.env.production?
  end
end
