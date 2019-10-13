class Scraping::Base
  require 'nokogiri'
  require 'open-uri'
  require 'line/bot'

  attr_reader :info

  def initialize(url)
    charset = nil
    html = open(url) do |u|
      charset = u.charset
      u.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    @info = article_info(doc)
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end
