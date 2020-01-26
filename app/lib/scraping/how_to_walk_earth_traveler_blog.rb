class Scraping::HowToWalkEarthTravelerBlog < Scraping::Base
  include LineMessages::HowToWalkEarthTravelerBlog
  attr_reader :blogs
  # 地球の歩き方特派員ブログ
  PAGE_URL = "https://tokuhain.arukikata.co.jp".freeze

  def initialize
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to(PAGE_URL)
    @blogs = []
    5.upto(14) do |num|
      @blogs << {
        title:    driver.find_element(:xpath, "//*[@id='main_column']/div[#{num}]/dt/a/img").attribute("alt"),
        content:  driver.find_element(:xpath, "//*[@id='main_column']/div[#{num}]/dd").text,
        page_url: driver.find_element(:xpath, "//*[@id='main_column']/div[#{num}]/dd/a").attribute("href"),
        image:    driver.find_element(:xpath, "//*[@id='main_column']/div[#{num}]/dt/a/img").attribute("src"),
      }
    end
  rescue => e
    error_client.push_message(
      ENV['LINE_USER_ID'],{
        "type": "text",
        "text": "#{e.class} has occurred in #{self.class}"
      }
    )
  end 
end
