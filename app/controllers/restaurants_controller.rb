class RestaurantsController < ApplicationController

  # 検索ページ
  def search
    @restaurants = Restaurant.search(params[:q], limit: 20)
  end

  # 詳細ページ
  def detail
    @restaurant = Restaurant.find(params[:id])
  end
end
