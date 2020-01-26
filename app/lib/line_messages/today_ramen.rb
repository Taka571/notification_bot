module LineMessages::TodayRamen
  def notify_article
    message = create_line_message
    raise if message.blank?
    response = client.push_message(ENV['LINE_USER_ID'], message)
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

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def create_line_message
    {
      "type": "flex",
      "altText": "今日(#{Time.zone.today.strftime("%Y/%m/%d")}の一杯) #{article_info[:shop_name]}",
      "contents":
      {
        "type": "carousel",
        "contents": [
          {
            "type": "bubble",
            "hero": {
              "type": "image",
              "size": "full",
              "aspectRatio": "20:13",
              "aspectMode": "cover",
              "url": article_info[:image],
              "action": {
                "type": "uri",
                "label": article_info[:shop_name],
                "uri": article_info[:shop_url],
              }
            },
            "body":
            {
              "type": "box",
              "layout": "vertical",
              "spacing": "sm",
              "contents": [
                {
                  "type": "text",
                  "text": "#{Time.zone.today.strftime('%Y/%m/%d')}\n今日の一杯",
                  "wrap": true,
                  "margin": "md",
                  "flex": 0,
                  "weight": "bold"
                },
                {
                  "type": "text",
                  "text": article_info[:shop_name],
                  "wrap": true,
                  "weight": "bold",
                  "size": "xl",
                  "action": {
                    "type": "uri",
                    "label": article_info[:shop_name],
                    "uri": article_info[:shop_url],
                  }
                },
                {
                  "type": "text",
                  "text": article_info[:place],
                  "wrap": true,
                  "color": "#aaaaaa",
                  "size": "sm"
                },
                {
                  "type": "box",
                  "layout": "baseline",
                  "contents": [
                    {
                      "type": "text",
                      "text": article_info[:article],
                      "wrap": true,
                      "weight": "bold",
                      "flex": 0
                    }
                  ]
                }
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
                    "label": "WEBSITE",
                    "uri": 'https://ramendb.supleks.jp/ippai'
                  }
                }
              ]
            }
          }
        ]
      }
    }
  end
end
