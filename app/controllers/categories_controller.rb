class CategoriesController < ApplicationController
  before_action :authenticate, only: [:create]

  def index
    render_cached_json 'api:categories:index' do
      categories = Category.includes(:addons).order(:position)
      ActiveModel::Serializer.build_json(self, categories, { })
    end
  end

  def create
    category = Category.new(category_params)
    if category.save
      render json: category, status: :created
    else
      head :unprocessable_entity
    end
  end

  def show
    category = Category.where(name: params[:name]).first
    if category
      render json: category
    else
      head :not_found
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :description, :position)
  end
end
