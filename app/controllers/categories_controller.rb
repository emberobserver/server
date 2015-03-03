class CategoriesController < ApplicationController
  def index
    categories = Category.includes(:addons).order(:position)
    render json: categories
  end

  def show
    category = Category.where(name: params[:name]).first
    if category
      render json: category
    else
      head :not_found
    end
  end
end
