class Scraping::Base
  include LineMessages::Base
  require "nokogiri"
  require "open-uri"
  require "line/bot"
  require "selenium-webdriver"
end
