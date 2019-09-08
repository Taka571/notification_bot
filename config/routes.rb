Rails.application.routes.draw do
  # get "/callback"  => "notifybots#index"
  # post "/callback" => "notifybots#callback"
  post "/recieve" => "notify_bots#recieve"
end
