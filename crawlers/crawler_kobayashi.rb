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

require "#{File.dirname(__FILE__)}/lib/my_string"

# main
#### 実行時オプションによる設定 ####
while f = ARGV.shift
  # デバッグモードに設定する
  if f == '-d'
    debug = true
  # ログを標準出力に切り替える
  elsif f == '-o'
    log_out = true
  elsif f == '-u'
    update = true
  # クロール深度を指定する
  # elsif /-d(\d+)$/ =~ f
  #   depth = $1.to_i
  # 指定された idのサイトだけを解析する
  elsif /-s(\d+)$/ =~ f
    site_id = Regexp.last_match(1).to_i
    force = true
  # それ以外
  else
    log.e_msg("main", 1, "illegal opiton #{f}")
    exit 1
  end
end

#### Logger ####
unless File.directory?("#{File.dirname(__FILE__)}/log")
  Dir.mkdir("#{File.dirname(__FILE__)}/log")
end
log = Logger.new(log_out ? $stderr : "#{File.dirname(__FILE__) }/log/crawl.log", 'weekly')
log.level = debug ? Logger::DEBUG : Logger::INFO

log.info("＜クローラ開始＞ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")

# 設定ファイルを取得
config = YAML.load_file("#{File.dirname(__FILE__)}/config.yaml")
get_uri = config['get_uri']
set_uri = URI(config['set_uri'])

#### 各サイトのクロール開始 ####
thread = []

sites = %w[kobayashi]
sites.each_with_index do |o, i|
  thread[i] = Thread.new do |t|
    #### クローラオブジェクト作成 ####
    require "#{File.dirname(__FILE__)}/crawler/#{o}"
    crawler = Object.const_get(o.capitalize).new

    #### ロガーをセット ####
    crawler.log = log

    #### 既存機械UID一覧を取得 ####
    log.info("#{crawler.company}: クロールサイト情報を取得します")
    # 更新を行うかどうか
    u = update ? 1 : ""
    # crawler.update = true if update != nil

    # クローラ深度(以降削除されてしまうため、未使用)
    # crawler.depth = depth if depth != nil
    url = "#{get_uri}/#{crawler.company_id}/edit?company=#{URI.encode_www_form_component(crawler.company)}&update=#{u}"
    # ex_json = open(URI.encode("#{get_uri}?id=#{crawler.company_id}&company=#{crawler.company}&update=#{u}")).read

    ex_json = URI.parse(url).read

    crawler.ex = JSON.parse(ex_json, symbolize_names: true, allow_nan: true)

    #### クロール開始 ####
    Thread.exit unless crawler.crawl

    ### 変換したJSONデータをPOST ####
    log.info("#{crawler.company}: 機械情報を保存します。")
    # Net::HTTP.new(set_uri.host, 80).start do |http|
    #   http.read_timeout = 9000

    #   q = {
    #     id: crawler.company_id.to_s,
    #     company: crawler.company,
    #     data: crawler.d.to_json,
    #     rex: crawler.rex.to_json
    #   }.map { |key, value| "#{CGI.escape(key)}=#{CGI.escape(value)}" }.join("&")

    #   res = http.post(set_uri.path, q)

    #   log.info("#{crawler.company}: #{res.body}")
    # end
  end
end

#### スレッドを結合 ####
thread.each(&:join)

log.info("＜クローラ完了＞ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")
exit
