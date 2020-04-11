class Scraping::RealTimeTrend < Scraping::Base
  include LineMessages::RealTimeTrend
  attr_reader :ranking
  EXEC_HOURS = [2, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23].freeze
  REAL_TIME_TREND_URL = "https://search.yahoo.co.jp/realtime".freeze

  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to(REAL_TIME_TREND_URL)
    @ranking = {}
    1.upto(10) do |num|
      # 1〜10位まで
      @ranking[num] = {
        text: driver.find_element(:xpath, "//*[@id='body']/div[2]/article/section/ol[1]/li[#{num}]/a").text,
        url:  driver.find_element(:xpath, "//*[@id='body']/div[2]/article/section/ol[1]/li[#{num}]/a").attribute("href"),
      }
    end
  end
end
