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
    return unless Scraping::HatenaHotEntry::EXEC_HOURS.include?(Time.zone.now.hour)

    Scraping::HatenaHotEntry.new(category: :all).notify
    Scraping::HatenaHotEntry.new(category: :it).notify
  end

  task qiita_trend: :environment do
    return unless Scraping::QiitaTrend::EXEC_HOURS.include?(Time.zone.now.hour)

    Scraping::QiitaTrend.new.notify
  end

  task traveler_blogs: :environment do
    Scraping::HowToWalkEarthTravelerBlog.new.notify
  end
end
