class Scraping::RealTimeTrend < Scraping::Base
  attr_reader :ranking
  REAL_TIME_TREND_URL = "https://search.yahoo.co.jp/realtime".freeze

  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to(REAL_TIME_TREND_URL)
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
    response = client.broadcast(content)
    raise unless response.code == "200"
  rescue => e
    client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "Error has occured: #{response.msg}"})
  end

  private

  def create_line_messages
    {
      "type": "flex",
      "altText": ranking_from_1st_to_10th,
      "contents": line_messages,
    }
  end

  def ranking_from_1st_to_10th
    <<~TEXT
      #{Time.zone.now.strftime("%Y/%m/%d/%H:%M")}                                                                                              
      1. #{ranking[1][:text]}\t
      2. #{ranking[2][:text]}\t
      3. #{ranking[3][:text]}\t
      4. #{ranking[4][:text]}\t
      5. #{ranking[5][:text]}\t
      6. #{ranking[6][:text]}\t
      7. #{ranking[7][:text]}\t
      8. #{ranking[8][:text]}\t
      9. #{ranking[9][:text]}\t
      10. #{ranking[10][:text]}\t
    TEXT
  end

  def line_messages
    ranks = ranking.sort.to_h.each_with_object({}) do |(k,v), rank|
      color = case k
      when 1
        "#E3AB00"
      when 2
        "#C9CACA"
      when 3
        "#BA6E40"
      else
        "#000000"
      end

      rank[k] = 
        {
          "type": "text",
          "text": "#{k}.   #{v[:text]}",
          "wrap": true,
          "weight": "bold",
          "size": "xl",
          "color": color,
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
