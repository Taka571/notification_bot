Rails.application.routes.draw do
  post "/restaurants" => "restaurants#show"

  namespace "api" do
    namespace "v1" do
      resources :restaurants, only: [:index, :show]
    end
  end
end
