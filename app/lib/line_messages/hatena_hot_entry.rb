module LineMessages::HatenaHotEntry
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
      config.channel_secret = ENV['LINE_TREND_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_TREND_CHANNEL_TOKEN']
    end
  end

  def create_line_messages
    {
      "type": "flex",
      "altText": ranking_from_1st_to_5th,
      "contents":
      {
        "type": "carousel",
        "contents": line_messages,
      }
    }
  end

  def ranking_from_1st_to_5th
    ranking_index = ""
    ranking.each do |rank, value|
      break if rank > 5
      ranking_index << "#{rank}. #{value[:title].truncate(20)}\t"
    end
    ranking_index
  end

  def line_messages
    ranking.map do |rank, value|
      {
        "type": "bubble",
        "hero": {
          "type": "image",
          "size": "full",
          "aspectRatio": "20:13",
          "aspectMode": "cover",
          "url": value[:image],
          "action": {
            "type": "uri",
            "label": "画像",
            "uri": value[:page_url],
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
              "text": "#{value[:users]} USERS",
              "wrap": true,
              "margin": "md",
              "flex": 0,
              "weight": "bold",
              "color": "#00a5de",
            },
            {
              "type": "text",
              "text": value[:title],
              "wrap": true,
              "weight": "bold",
              "size": "xl",
              "action": {
                "type": "uri",
                "label": value[:title].truncate(30),
                "uri": value[:page_url],
              }
            },
            {
              "type": "text",
              "text": value[:category],
              "wrap": true,
              "color": "#aaaaaa",
              "size": "sm"
            }
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
                "label": "はてブで見る",
                "uri": value[:comment_page_url]
              }
            }
          ]
        }
      }
    end
  end
end
