class Scraping::QiitaTrend < Scraping::Base
  include LineMessages::QiitaTrend
  attr_reader :ranking
  TREND_URL = "https://qiita.com".freeze
  EXEC_HOURS = [7, 15, 20].freeze

  # TODO: Scraping::RealTimeTrend.new.crawling_qiitaみたいに統合する
  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to(TREND_URL)
    @ranking = {}
    1.upto(10) do |num|
      @ranking[num] = {
        title: driver.find_element(:xpath, "/html/body/div[1]/div[3]/div[2]/div/div[2]/div/div/div[3]/div[#{num}]/div/a").text,
        url:   driver.find_element(:xpath, "/html/body/div[1]/div[3]/div[2]/div/div[2]/div/div/div[3]/div[#{num}]/div/a").attribute("href"),
        like:  driver.find_element(:xpath, "/html/body/div[1]/div[3]/div[2]/div/div[2]/div/div/div[3]/div[#{num}]/div/div/div").text,
      }
    end
  end
end
