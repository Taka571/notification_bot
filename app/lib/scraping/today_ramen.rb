class Scraping::TodayRamen < Scraping::Base
  include LineMessages::TodayRamen
  attr_reader :article_info

  TODAY_RAMEN_URL = 'https://ramendb.supleks.jp/ippai'.freeze

  def initialize
    charset = nil
    html = open(TODAY_RAMEN_URL) do |u|
      charset = u.charset
      u.read
    end
    page_info = Nokogiri::HTML.parse(html, nil, charset)
    @article_info = fetch_article_info_from_page(page_info)
  end

  private

  def fetch_article_info_from_page(page_info)
    {
      article:   page_info.xpath("//*[@id='ippai']/div[3]/p").text.truncate(100),
      image:     page_info.xpath("//*[@id='ippai']/div[2]/a/img").first.values[0],
      place:     page_info.xpath("//*[@id='ippai']/h2/div/div[2]/text()[1]").text,
      shop_name: page_info.xpath("//*[@id='ippai']/h2/div/div[1]/a").text,
      shop_url:  "https://ramendb.supleks.jp" + page_info.xpath("//*[@id='ippai']/h2/div/div[1]/a").first.values[0]
    }
  end
end
