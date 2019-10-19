module Api
  module V1
    class RestaurantsController < ApplicationController
      def index
        restaurants = Restaurant.all.order(:open_date)
        if restaurants.present?
          render json: { status: "success", messages: "Loaded all restaurant", data: restaurants }
        else
          render json: { status: "failure", messages: "No records" }
        end
      end

      def show
        if restaurant = Restaurant.find(params[:id])
          render json: { status: "success", messages: "Loaded restaurant, id=#{restaurant.id}", date: restaurant}
        else
          render json: { status: "failure", messages: "Not found" }
        end
      end
    end
  end
end
