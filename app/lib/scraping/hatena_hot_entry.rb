class Scraping::HatenaHotEntry < Scraping::Base
  attr_reader :ranking
  ALL_HOT_ENTRY_URL = "https://b.hatena.ne.jp/hotentry/all".freeze

  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to(ALL_HOT_ENTRY_URL)
    @ranking = {}

    # 1位
    begin
      image_url = driver
        .find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/div/ul/li/div/div[2]/div[1]/a/p[2]/span")
        .attribute("style")
        .slice(/(?<=url\()(.*)(.*)(?=\);)/) # cssのbackground-imageからimage URLを抜き出す
        .gsub("\"", "") # 稀に""文字が混ざりBad Requestになるので置換する

      raise Selenium::WebDriver::Error::NoSuchElementError if image_url.nil?
    rescue Selenium::WebDriver::Error::NoSuchElementError # 画像が見つからなかったら404画像を差し込む
      image_url = "https://cdn-ak.f.st-hatena.com/images/fotolife/d/dunbine6000/20190505/20190505190158.png"
    end

    @ranking[1] = {
      users: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/div/ul/li/div/div[2]/span/a/span").text,
      comment_page_url: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/div/ul/li/div/div[2]/span/a").attribute("href"),
      title: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/div/ul/li/div/div[2]/h3/a").text.gsub("\"", ""),
      page_url: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/div/ul/li/div/div[2]/h3/a").attribute("href"),
      category: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/div/ul/li/div/div[2]/div[2]/ul[1]/li[1]/a").text,
      image: image_url,
    }

    # 2位〜10位まで
    1.upto(9) do |num|
      begin
        image_url = driver
          .find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/div[1]/a/p[2]/span")
          .attribute("style")
          .slice(/(?<=url\()(.*)(.*)(?=\);)/)
          .gsub("\"", "")

        raise Selenium::WebDriver::Error::NoSuchElementError if image_url.nil?
      rescue Selenium::WebDriver::Error::NoSuchElementError
        image_url = "https://cdn-ak.f.st-hatena.com/images/fotolife/d/dunbine6000/20190505/20190505190158.png"
      end

      @ranking[num + 1] = {
        users: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/span/a/span").text,
        comment_page_url: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/span/a").attribute("href"),
        title: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/h3/a").text.gsub("\"", ""),
        page_url: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/h3/a").attribute("href"),
        category: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/div[2]/ul[1]/li[1]/a").text,
        image: image_url,
      }
    end
  end

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

  def create_line_messages
    {
      "type": "flex",
      "altText": ranking_from_1st_to_10th,
      "contents":
      {
        "type": "carousel",
        "contents": line_messages,
      }
    }
  end

  def ranking_from_1st_to_10th
    <<~TEXT
      1. #{ranking[1][:title].truncate(10)}\t
      2. #{ranking[2][:title].truncate(10)}\t
      3. #{ranking[3][:title].truncate(10)}\t
      4. #{ranking[4][:title].truncate(10)}\t
      5. #{ranking[5][:title].truncate(10)}\t
      6. #{ranking[6][:title].truncate(10)}\t
      7. #{ranking[7][:title].truncate(10)}\t
      8. #{ranking[8][:title].truncate(10)}\t
      9. #{ranking[9][:title].truncate(10)}\t
      10. #{ranking[10][:title].truncate(10)}\t
    TEXT
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
              "weight": "bold"
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
          "backgroundColor": "#f5f5f5",
          "contents": [
            {
              "type": "button",
              "style": "link",
              "action": {
                "type": "uri",
                "label": "はてなで見る",
                "uri": value[:comment_page_url]
              }
            }
          ]
        }
      }
    end
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_TREND_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_TREND_CHANNEL_TOKEN']
    end
  end
end
