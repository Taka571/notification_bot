class Scraping::RealTimeTrend < Scraping::Base
  attr_reader :ranking
  REAL_TIME_TREND_URL = "https://search.yahoo.co.jp/realtime".freeze

  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to "https://search.yahoo.co.jp/realtime"
    @ranking = {}
    1.upto(5) do |num|
      # 1〜5位まで
      @ranking[num] = {
        text: driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[1]/div[#{num}]/p/a").text,
        url: driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[1]/div[#{num}]/p/a").attribute("href"),
      }

      # 6〜10位まで
      @ranking[num + 5] = {
        text: driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[2]/div[#{num}]/p/a").text,
        url: driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[2]/div[#{num}]/p/a").attribute("href"),
      }
    end
  end

  def notify
    content = create_line_messages
    raise if content.blank?
    response = client.push_message(ENV['LINE_USER_ID'], content)
    raise unless response.code == "200"
  rescue => e
    client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "エラー発生中"})
  end

  private

  def create_line_messages
    {
      "type": "flex",
      "altText": "#{Time.zone.now.strftime("%Y/%m/%d %H:%S")}\nトレンドランキング",
      "contents": line_messages,
    }
  end

  def line_messages
    ranks = ranking.sort.to_h.each_with_object({}) do |(k,v), rank|
      rank[k] = 
        {
          "type": "text",
          "text": "#{k}位. #{v[:text]}",
          "wrap": true,
          "weight": "bold",
          "size": "xl",
          "action": {
            "type": "uri",
            "label": "#{k}位",
            "uri": "#{v[:url]}",
          }
        }
    end

    {
      "type": "bubble",
      "body":
      {
        "type": "box",
        "layout": "vertical",
        "spacing": "sm",
        "contents": [
          {
            "type": "text",
            "text": "#{Time.zone.now.strftime("%Y/%m/%d %H:%S")}\nトレンドランキング",
            "wrap": true,
            "margin": "md",
            "flex": 0,
            "weight": "bold"
          },
          ranks[1],
          ranks[2],
          ranks[3],
          ranks[4],
          ranks[5],
          ranks[6],
          ranks[7],
          ranks[8],
          ranks[9],
          ranks[10],
        ]
      },
      "footer": {
        "type": "box",
        "layout": "vertical",
        "spacing": "sm",
        "backgroundColor": "#f5f5f5",
        "contents": [
          {
            "type": "button",
            "style": "link",
            "action": {
              "type": "uri",
              "label": "ALL RANKS",
              "uri": "https://search.yahoo.co.jp/realtime#mode=detail",
            }
          }
        ]
      }
    }
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_TREND_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_TREND_CHANNEL_TOKEN']
    end
  end
end
