class CategoriesController < ApplicationController
  def index
    render_cached_json 'api:categories:index' do
      categories = Category.includes(:addons).order(:position)
      ActiveModel::Serializer.build_json(self, categories, { })
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
end
