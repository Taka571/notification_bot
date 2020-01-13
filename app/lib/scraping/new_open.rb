class Scraping::NewOpen < Scraping::Base
  attr_reader :saved_restaurant_ids

  RAMEN_NEW_OPEN_URL = 'https://tabelog.com/tokyo/rstLst/cond16-00-00/ramen/'.freeze

  def initialize
    charset = nil
    html = open(RAMEN_NEW_OPEN_URL) do |u|
      charset = u.charset
      u.read
    end
    page_info = Nokogiri::HTML.parse(html, nil, charset)
    @saved_restaurant_ids = save_new_open_restaurants_from_page(page_info)
  end

  def notify
    if saved_restaurant_ids.blank?
      client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "新着のオープンはありません"})
      return
    end
    messages = Restaurant.create_line_messages(saved_restaurant_ids)
    response = client.push_message(ENV['LINE_USER_ID'], messages)
    raise unless response.code == "200"
  rescue => e
    client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "エラー発生中"})
  end

  private

  def save_new_open_restaurants_from_page(page_info)
    res = page_info.xpath("//*[@id='column-main']/ul/li")
    restaurant_ids = res.map.with_index(1) do |r, i|
      begin
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
      rescue => e
        client.push_message(ENV['LINE_USER_ID'], {"type": "text", "text": "エラー発生: #{new_restaurant}"})
      end
    end.compact.take(10)
  end
end
