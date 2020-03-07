class Scraping::RealTimeTrend < Scraping::Base
  include LineMessages::RealTimeTrend
  attr_reader :ranking
  EXEC_HOURS = [2, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23].freeze
  REAL_TIME_TREND_URL = "https://search.yahoo.co.jp/realtime".freeze

  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to(REAL_TIME_TREND_URL)
    @ranking = {}
    1.upto(5) do |num|
      # 1〜5位まで
      @ranking[num] = {
        text: driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[1]/div[#{num}]/p/a").text,
        url:  driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[1]/div[#{num}]/p/a").attribute("href"),
      }

      # 6〜10位まで
      @ranking[num + 5] = {
        text: driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[2]/div[#{num}]/p/a").text,
        url:  driver.find_element(:xpath, "//*[@id='Te']/div[2]/div[2]/div[#{num}]/p/a").attribute("href"),
      }
    end
  end
end
