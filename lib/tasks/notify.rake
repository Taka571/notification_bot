namespace :notify do
  task today_ramen: :environment do
    Scraping::TodayRamen.new(Scraping::TodayRamen::TODAY_RAMEN_URL).notify_article
  end

  task new_open: :environment do
    Scraping::NewOpen.new(Scraping::NewOpen::RAMEN_NEW_OPEN_URL).notify
  end
end
