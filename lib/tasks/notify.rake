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

  task real_time_trend: :environment do
    Scraping::RealTimeTrend.new.notify
  end

  task hatena_hot_entry: :environment do
    Scraping::HatenaHotEntry.new.notify
  end
end
