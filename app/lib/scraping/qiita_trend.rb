class Scraping::QiitaTrend < Scraping::Base
  attr_reader :ranking
  TREND_URL = "https://qiita.com".freeze

  # TODO: Scraping::RealTimeTrend.new.crawling_qiitaみたいに統合する
  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to(TREND_URL)
    @ranking = {}
    1.upto(10) do |num|
      @ranking[num] = {
        title: driver.find_element(:xpath, "/html/body/div[1]/div[3]/div[2]/div/div[2]/div/div/div[3]/div[#{num}]/div/a").text,
        url: driver.find_element(:xpath, "/html/body/div[1]/div[3]/div[2]/div/div[2]/div/div/div[3]/div[#{num}]/div/a").attribute("href"),
        like: driver.find_element(:xpath, "/html/body/div[1]/div[3]/div[2]/div/div[2]/div/div/div[3]/div[#{num}]/div/div/div").text,
      }
    end
  end

  def notify
    messages = create_line_messages
    raise if messages.blank?
    response = client.broadcast(messages)
    raise unless response.code == "200"
  rescue => e
    error_client.push_message(
      ENV['LINE_USER_ID'],{
        "type": "text",
        "text": "Error has occurred in #{self.class}, reason: #{response.body&.force_encoding("UTF-8")}"
      }
    )
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
      1. #{ranking[1][:title]}\t
      2. #{ranking[2][:title]}\t
      3. #{ranking[3][:title]}\t
      4. #{ranking[4][:title]}\t
      5. #{ranking[5][:title]}\t
      6. #{ranking[6][:title]}\t
      7. #{ranking[7][:title]}\t
      8. #{ranking[8][:title]}\t
      9. #{ranking[9][:title]}\t
      10. #{ranking[10][:title]}\t
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
          "text": "#{k}. #{v[:title]}  👍#{v[:like]}",
          "wrap": true,
          "weight": "bold",
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
              "label": "Qiitaで見る",
              "uri": "https://qiita.com",
            }
          }
        ]
      }
    }
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_QIITATREND_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_QIITATREND_CHANNEL_TOKEN']
    end
  end
end
