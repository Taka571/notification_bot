class Scraping::HatenaHotEntry < Scraping::Base
  attr_reader :ranking
  BASE_URL = "https://b.hatena.ne.jp/hotentry".freeze
  EXEC_HOURS = [5, 8, 11, 14, 17, 20, 23].freeze

  # category => all, it, general, social, economics, life, knowledge, fun, entertainment, game

  def initialize(category: :all)
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to("#{BASE_URL}/#{category}")
    @ranking = {}

    # 1位
    begin
      image_url = driver
        .find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/div/ul/li/div/div[2]/div[1]/a/p[2]/span")
        .attribute("style")
        .slice(/(?<=url\()(.*)(.*)(?=\);)/) # cssのbackground-imageからimage URLを抜き出す
        .gsub("\"", "") # 稀に""文字が混ざりBad Requestになるので置換する

      raise if image_url.nil?        # 画像が見つからなかった場合
      raise if image_url.size > 1000 # 画像URLの文字数が1000文字以上だった場合Bad Requestになる
    rescue
      # 例外が発生した場合は404画像を差し込む
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

        raise if image_url.nil?        # 画像が見つからなかった場合
        raise if image_url.size > 1000 # 画像URLの文字数が1000文字以上だった場合Bad Requestになる
      rescue
        # 例外が発生した場合は404画像を差し込む
        image_url = "https://cdn-ak.f.st-hatena.com/images/fotolife/d/dunbine6000/20190505/20190505190158.png"
      end

      begin
        @ranking[num + 1] = {
          users: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/span/a/span").text,
          comment_page_url: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/span/a").attribute("href"),
          title: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/h3/a").text.gsub("\"", ""),
          page_url: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/h3/a").attribute("href"),
          category: driver.find_element(:xpath, "//*[@id='container']/div[4]/div/div[1]/section/ul/li[#{num}]/div/div[2]/div[2]/ul[1]/li[1]/a").text,
          image: image_url,
        }
      rescue => e
        @ranking.delete(num + 1) # 広告の場合取れない＆いらないので削除する
      end
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

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_TREND_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_TREND_CHANNEL_TOKEN']
    end
  end
end
