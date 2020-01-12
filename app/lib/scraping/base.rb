class Scraping::Base
  require 'nokogiri'
  require 'open-uri'
  require 'line/bot'
  require 'selenium-webdriver'

  private

  # Override this method in child class.
  # This method specifies the line channel individually.
  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end
