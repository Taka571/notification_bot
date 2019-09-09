class Restaurant < ApplicationRecord
  def self.create_line_messages(ids)
    restaurant = where(id: ids)
    {
      "type": "flex",
      "altText": "ニューオープン",
      "contents":
      {
        "type": "carousel",
        "contents":  restaurant.map { |r| r.line_messages },
      }
    }
  end

  def line_messages
    {
      "type": "bubble",
      "hero": {
        "type": "image",
        "size": "full",
        "aspectRatio": "20:13",
        "aspectMode": "cover",
        "url": image,
        "action": {
          "type": "uri",
          "label": name,
          "uri": url,
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
            "text": "#{open_date.strftime('%Y/%m/%d')}オープン",
            "wrap": true,
            "margin": "md",
            "flex": 0,
            "weight": "bold"
          },
          {
            "type": "text",
            "text": name,
            "wrap": true,
            "weight": "bold",
            "size": "xl",
            "action": {
              "type": "uri",
              "label": name,
              "uri": url,
            }
          },
          {
            "type": "text",
            "text": place,
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
        "backgroundColor": "#f5f5f5",
        "contents": [
          {
            "type": "button",
            "style": "link",
            "action": {
              "type": "uri",
              "label": "WEBSITE",
              "uri": url
            }
          }
        ]
      }
    }
  end
end
