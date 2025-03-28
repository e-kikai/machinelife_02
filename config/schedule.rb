# Rails.rootを使用するために必要
require File.expand_path("#{File.dirname(__FILE__)}/environment")

# 事故防止の為RAILS_ENVの指定が無い場合にはdevelopmentを使用する
rails_env = ENV['RAILS_ENV'] || "development"

# cronを実行する環境変数をセット
set :environment, rails_env

# 出力先のログファイルの指定
set :output, Rails.root.join("log/cron.log").to_s
# set :output, nil

# env :PATH, ENV['PATH']
ENV.each { |k, v| env(k, v) }
env :CRON_TZ, "Asia/Tokyo"

if rails_env == "production"
  # sitemap
  every 1.day, at: '5:00 am' do
    rake '-s sitemap:refresh'
  end
end

unless rails_env == "staging" # stagingではクローラは廻さない
  # 同期
  crawler_path =
    if rails_env == "development"
      "/usr/local/bin/ruby #{Rails.root.join('crawlers')}"
    else
      "/usr/local/bin/ruby /var/www/machinelife_02/apps/current/crawlers"
    end

  every 1.day, at: ['10:00 am', '6:00 pm'] do
    command "#{crawler_path}/crawler_main.rb"
  end

  every :day, at: '1:00 am' do
    command "#{crawler_path}/crawler_main.rb -u"
  end

  every :day, at: '4:00 am' do
    command "#{crawler_path}/crawler_main.rb -skobayashi -i"
  end

  # every 1.minute do
  #   command 'echo "test1"'
  # end

  # every :day, at: '4:30 am' do
  #   rake "session:sweep"
  # end
end
