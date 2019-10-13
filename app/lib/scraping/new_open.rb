class Scraping::NewOpen < Scraping::Base

  attr_reader :info

  RAMEN_NEW_OPEN_URL = 'https://tabelog.com/tokyo/rstLst/cond16-00-00/ramen/'.freeze

  def initialize
    url = RAMEN_NEW_OPEN_URL
    charset = nil
    html = open(url) do |u|
      charset = u.charset
      u.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    @info = article_info(doc)
  end

  def notify
    if info.blank?
      client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "新着のオープンはありません"})
      return
    end
    content = Restaurant.create_line_messages(info)
    response = client.push_message(ENV['LINE_USER_ID'], content)
    raise unless response.code == "200"
  rescue => e
    client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "エラー発生中"})
  end

  private

  def article_info(doc)
    res = doc.xpath("//*[@id='column-main']/ul/li")
    restaurant_ids = res.map.with_index(1) do |r, i|
      new_restaurant = Restaurant.new(
        name: r.xpath("//li[#{i}]/div[2]/div[1]/div/div/div/a")&.text || "no name",
        image: r.xpath("//li[#{i}]/div[2]/div[2]").css("img")&.first&.values&.slice(2) || "no image",
        place: r.xpath("//li[#{i}]/div[2]/div[1]/div/div/div/span")&.text[/(.*m)/] || "not found",
        url: r.xpath("//li[#{i}]/div[2]/div[1]/div/div/div/a")&.first&.values&.slice(3) || "not found",
        open_date: r.xpath("//li[#{i}]/div[2]/div[2]/div[1]/div[2]/p").text.gsub("年", "/").to_date
      )
      next if Restaurant.find_by(name: new_restaurant.name) || new_restaurant.name == "no name" || new_restaurant.name == ""
      new_restaurant.save!
      new_restaurant.id
    end.compact.take(10)
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end
