require "pry"
require "twitter"
require "curb"
require "json"

class MonitoringBoron
  def initialize(conf)
    @conf = conf
    @rest = Twitter::REST::Client.new(@conf)
    @stream = Twitter::Streaming::Client.new(@conf)
  end

  def run
    puts "--------------------StartMonitoring--------------------"
    @stream.user do |tweet|
      puts "@#{tweet.user.screen_name} #{tweet.full_text}"
      next unless tweet.user.screen_name == "5percent_Dora"  
      next unless tweet.full_text =~ /チンポ（ﾎﾞﾛﾝ/
      slack_post(tweet)
    end
  end
  def slack_post(tweet)
    Curl.post(ENV.fetch("SLACK_WEBHOOKS_TOKEN"), { 
      channel: "#bot_tech",
      username: "ドラえもんﾎﾞﾛﾝのお知らせ",
      icon_emoji: ":squirrel:",
      attachments: [{
        author_icon:    tweet.user.profile_image_url.to_s,
        author_name:    tweet.user.name,
        author_subname: "@#{tweet.user.screen_name}",
        text:           tweet.full_text,
        author_link:    tweet.uri.to_s,
        color:          tweet.user.profile_link_color
      }]
    }.to_json)
  end
end

CONF = {
  consumer_key:        ENV.fetch("CONSUMER_KEY"),
  consumer_secret:     ENV.fetch("CONSUMER_SECRET"),
  access_token:        ENV.fetch("ACCESS_TOKEN"),
  access_token_secret: ENV.fetch("ACCESS_TOKEN_SECRET")
}

app = MonitoringBoron.new(CONF)
app.run
