module LineMessages::HowToWalkEarthTravelerBlog
  def notify
    line_messages = create_line_messages
    raise if line_messages.blank?
    response = client.push_message(ENV['LINE_USER_ID'], line_messages)
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
      config.channel_secret = ENV['LINE_HTWETB_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_HTWETB_CHANNEL_TOKEN']
    end
  end

  def create_line_messages
    {
      "type": "flex",
      "altText": blogs.map {|blog| blog[:title]}.join(" / ").truncate(40),
      "contents":
      {
        "type": "carousel",
        "contents": line_messages,
      }
    }
  end

  def line_messages
    blogs.map do |blog|
      {
        "type": "bubble",
        "hero": {
          "type": "image",
          "size": "full",
          "aspectRatio": "20:13",
          "aspectMode": "cover",
          "url": blog[:image],
          "action": {
            "type": "uri",
            "label": "画像",
            "uri": blog[:page_url],
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
              "text": blog[:title],
              "wrap": true,
              "margin": "xl",
              "flex": 0,
              "weight": "bold",
            },
            {
              "type": "text",
              "text": blog[:content],
              "wrap": true,
              "size": "md",
              "action": {
                "type": "uri",
                "label": "content",
                "uri": blog[:page_url],
              }
            },
          ]
        },
        "footer": {
          "type": "box",
          "layout": "vertical",
          "spacing": "sm",
          "backgroundColor": "#00a5de",
          "contents": [
            {
              "type": "button",
              "style": "link",
              "action": {
                "type": "uri",
                "label": "全て見る",
                "uri": blog[:page_url]
              }
            }
          ]
        }
      }
    end
  end
end
