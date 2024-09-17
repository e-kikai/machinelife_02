#! ruby -Ku
# クローラクラスのソースファイル
# Author::    川端洋平
# Date::      2011/05/26
# Copyright:: Copyright (c) 2011 川端洋平
require 'rubygems'
require 'mechanize'
require 'kconv'
require 'nkf'
require 'open-uri'
require 'uri'
require 'logger'
require 'net/http'
require 'json'
require 'yaml'
require 'active_support'
require 'time'

require "#{File.dirname(__FILE__)}/lib/my_string"

# main
#### 実行時オプションによる設定 ####
sites = []
while f = ARGV.shift
  case f
  when "-d"; debug = true # デバッグモードに設定する
  when "-o"; log_out = true # ログを標準出力に切り替える
  when "-u"; update = true # 更新
  # when /-d(\d+)$/; depth = $1.to_i # クロール深度を指定する
  when /-s([a-zA-Z0-9]+)$/; sites << Regexp.last_match(1); # 指定されたサイトだけを解析する
  else puts "illegal opiton #{f}"
  end
end

#### Logger ####
Dir.mkdir("#{File.dirname(__FILE__)}/log") unless File.directory?("#{File.dirname(__FILE__)}/log")

log = Logger.new(log_out ? $stderr : "#{File.dirname(__FILE__)}/log/crawl.log", 'weekly')
log.level = debug ? Logger::DEBUG : Logger::INFO

log.info("＜クローラ開始＞ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")

# 設定ファイルを取得
config = YAML.load_file("#{File.dirname(__FILE__)}/config.yaml")
get_uri = config['get_uri']
set_uri = config['set_uri']
#### 各サイトのクロール開始 ####
sites = config['sites'] if sites.empty?

### 並列クロール ###
THREAD_NUM = 3
locks = Queue.new
3.times { locks.push :lock }

threads = sites.filter_map do |o|
  Thread.new do
    lock = locks.pop

    #### クローラオブジェクト作成 ####
    require "#{File.dirname(__FILE__)}/crawler/#{o}"
    crawler = Object.const_get(o.capitalize).new

    #### ロガーをセット ####
    crawler.log = log

    #### 既存機械UID一覧を取得 ####
    log.info("#{crawler.company}: クロールサイト情報を取得します")
    # 更新を行うかどうか
    u = update ? "?update=1" : ""

    # クローラ深度(以降削除されてしまうため、未使用)
    # crawler.depth = depth if depth != nil
    url = "#{get_uri}/#{crawler.company_id}/#{crawler.company}/#{u}"

    log.info url
    ex_json = URI.parse(Addressable::URI.parse(url).normalize.to_s).read

    crawler.ex = JSON.parse(ex_json, symbolize_names: true, allow_nan: true)

    #### クロール開始 ####
    Thread.exit unless crawler.crawl

    ### 変換したJSONデータをPOST ####
    if crawler.rex.empty?
      log.info("#{crawler.company}: 在庫が0になってしまうので、処理を停止。")
    else
      log.info("#{crawler.company}: 機械情報を保存します。")
      uri = Addressable::URI.parse("#{set_uri}/#{crawler.company_id}/#{crawler.company}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 9000
      query = URI.encode_www_form({ datas: crawler.d.to_json, rex: crawler.rex.to_json })

      http.start do
        res = http.patch(uri.path, query)
        log.info("#{crawler.company}: #{res.body}")
      end
    end

    locks.push lock
  end
end

#### スレッドを結合 ####
threads.each(&:join)

log.info("＜クローラ完了＞ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")
exit
