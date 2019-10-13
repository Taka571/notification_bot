namespace :notify do
  task today_ramen: :environment do
    TodayRamen.new.(Scraping::NewOpen::RAMEN_NEW_OPEN_URL).notify_article
  end

  task new_open: :environment do
    NewOpen.new.(Scraping::TodayRamen::TODAY_RAMEN_URL).notify
  end
end
