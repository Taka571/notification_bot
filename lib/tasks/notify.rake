namespace :notify do
  task today_ramen: :environment do
    TodayRamen.new.notify_article
  end
end
