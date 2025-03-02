module LinkSource
  extend ActiveSupport::Concern

  included do
    before_save :check_robot

    # scope :ignore_hosts, -> { where.not(host: IGNORE_HOSTS) }
    scope :ignore_hosts, -> { where("host !~* ?", "^(#{IGNORE_HOSTS.join('|')})").where("ip !~* ?", "^(#{IGNORE_IPS.join('|')})") }
  end

  ROBOTS = /(goo|google|yahoo|naver|ahrefs|msnbot|bot|crawl|amazonaws|rate-limited-proxy)/i
  KWDS   =
    {
      "smd" => "同じ型式", "nmr" => "似た機械", "sge" => "同ジャンル", "hst" => "閲覧履歴", "sad" => "同じ都道府県",

      # トップページキーワード検索
      "kma" => "メーカー", "kmo" => "型式",

      # 表示形式
      "crd" => "カード表示", "lst" => "リスト表示",

      # リロード
      "reload" => "リロード", "back" => "履歴",

      # 一括配信メール
      "mail" => "メール", "cmp" => "Mailchimp", "rss" => "RSS",
      "cnu" => "ユーザ新着", "cna" => "会員新着",

      # 外部サイト
      "omdc" => "電子入札システム", "ekikai" => "e-kikai", "mnok" => "ものオク",

      # モバイル
      "pc" => "PC", "mb" => "モバイル",

      # 検索 or 詳細
      "src" => "検索結果", "dtl" => "詳細", "com" => "会社", "blk" => "一括", "ukt" => "売りたし買いたし",

      # MAI
      "mai" => "MAI", "adv" => "アドバイス"
    }.freeze
  IGNORE_HOSTS = %w[mcnam.rsglab.com v22024].freeze
  IGNORE_IPS   = %w[219.145. 47.82. 222.90.].freeze

  ### リンク元の生成 ###
  def link_source
    self.class.link_source_base(r, referer)
  end

  module ClassMethods
    def link_source_base(ref = "", referer = "")
      res = []
      # refererから取得
      res <<
        case referer

        # 検索・SNS
        when /www\.google\.co/;   "Gogle"
        when /search\.yahoo\.co/; "Yahoo"
        when /bing\.com/;         "bing"
        when /baidu\.com/;        "百度"
        when /t\.co/;             "Twitter"
        when /facebook\.com/;     "FB"
        when /youtube\.com/;      "YouTube"
        # when /googleads\.g\.doubleclick\.net/; "広告"
        # when %r{tpc\.googlesyndication\.com};  "広告"
        # when %r{www\.googleadservices\.com};   "広告"

        # e-kikai
        # when /www\.zenkiren\.net/; "マシンライフ"
        when /zenkiren\.org/; "全機連"
        when /e-kikai\.com/; "e-kikai"
        when /(xn--4bswgw9cs82at4b485i\.jp|大阪機械団地\.jp)/; "電子入札システム"
        when /mnok\.net/; "ものオク"

        # 電子入札システム内
        when /#{Rails.application.credentials.site[:machinelife]}(.*)$/
          path = Regexp.last_match(1)
          case path
          when %r{^/news/machines(.*)$};           "機械新着 : #{Regexp.last_match(1)}"
          when %r{^/news/tools(.*)$};              "工具新着 : #{Regexp.last_match(1)}"
          when %r{^/machines/([\d]+)};             "詳細 : #{Regexp.last_match(1)}"
          when %r{^/machines/large_genre/([\d]+)}; "中ジャンル : #{Regexp.last_match(1)}"
          when %r{^/machines/genre/([\d]+)};       "ジャンル : #{Regexp.last_match(1)}"
          when %r{^/machines/maker/([\d]+)};       "メーカー : #{Regexp.last_match(1)}"
          when %r{^/machines/addr1/(.+)};          "都道府県 : #{Regexp.last_match(1)}"
          when %r{^/machines/company/([\d]+)};     "出品会社 : #{Regexp.last_match(1)}"
          when %r{^/machines\?k=(.*?)(&|$)};       "キーワード : #{Regexp.last_match(1)}"
          when %r{^/helps};                        "ヘルプ"
          when %r{^/admin/catalogs/search\?(.*)};  "電子カタログ検索 : #{Regexp.last_match(1)}"
          when %r{^/admin};                        "組合員ページ"
          when %r{^/system};                       "管理者ページ"
          when %r{^/contacts};                     "問合せ"
          when %r{^(\?|$|/$)};                     "トップページ"
          else; path
          end

        when %r{/(.*?)(/|$)}; Regexp.last_match(1)
        # else; "(不明)"
        end

      # rel から取得
      res.concat(ref.split("_").map { |kwd| KWDS[kwd] || kwd } || []).compact.join(' | ').to_s
    end
  end

  def browse_info
    browser = Browser.new(ua)

    res = []
    res << browser.device.name unless browser.device.unknown?
    res << browser.platform.name << browser.platform.version unless browser.platform.unknown?
    res << browser.name << browser.version unless browser.unknown?

    res.join(' ')
  end

  private

  def check_robot
    throw(:abort) unless ip.present? && host !~ ROBOTS && IGNORE_HOSTS.exclude?(host)
  end
end
