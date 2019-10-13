class Scraping::TodayRamen < Scraping::Base
  TODAY_RAMEN_URL = 'https://ramendb.supleks.jp/ippai'.freeze

  def notify_article
    content = create_content
    raise if content.blank?
    response = client.push_message(ENV['LINE_USER_ID'], content)
    raise unless response.code == "200"
  rescue => e
    client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "エラー発生中"})
  end

  private

  def article_info(doc)
    {
      article: doc.xpath("//*[@id='ippai']/div[3]/p").text.truncate(100),
      image: doc.xpath("//*[@id='ippai']/div[2]/a/img").first.values[0],
      place: doc.xpath("//*[@id='ippai']/h2/div/div[2]/text()[1]").text,
      shop_name: doc.xpath("//*[@id='ippai']/h2/div/div[1]/a").text,
      shop_url: 'https://ramendb.supleks.jp' + doc.xpath("//*[@id='ippai']/h2/div/div[1]/a").first.values[0]
    }
  end

  def create_content
    {
      "type": "flex",
      "altText": "今日(#{Time.zone.today.strftime("%Y/%m/%d")}の一杯)",
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
              "url": info[:image],
              "action": {
                "type": "uri",
                "label": info[:shop_name],
                "uri": info[:shop_url],
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
                  "text": info[:shop_name],
                  "wrap": true,
                  "weight": "bold",
                  "size": "xl",
                  "action": {
                    "type": "uri",
                    "label": info[:shop_name],
                    "uri": info[:shop_url],
                  }
                },
                {
                  "type": "text",
                  "text": info[:place],
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
                      "text": info[:article],
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
