Rails.application.routes.draw do
  post "/restaurants" => "restaurants#show"
end
