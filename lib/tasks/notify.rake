namespace :notify do
  task today_ramen: :environment do
    TodayRamen.new.notify_article
  end

  task new_open: :environment do
    NewOpen.new.notify
  end
end
