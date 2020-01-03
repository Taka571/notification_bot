namespace :notify do
  task today_ramen: :environment do
    Scraping::TodayRamen.new.notify_article
  end

  task new_open: :environment do
    Scraping::NewOpen.new.notify
  end

  task garbage: :environment do
    GarbageDay.notify
  end
end
