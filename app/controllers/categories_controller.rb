class CategoriesController < ApplicationController
  before_action :authenticate, only: [:create, :update]

  def index
    render_cached_json 'api:categories:index' do
      categories = Category.includes(:addons).order(:position)
      ActiveModel::Serializer.build_json(self, categories, { })
    end
  end

  def create
    category = Category.new(category_params)

    Category.transaction do
      increment_category_positions(category.parent_id, category.position)
      if category.save
        Rails.cache.delete 'api:categories:index'
        render json: category, status: :created
      else
        head :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def update
    begin
      @category = Category.find(params[:id])
    rescue
      head :not_found
      return
    end
    Category.transaction do
      decrement_category_positions(@category.parent_id, @category.position + 1)
      @category.position = -999
      increment_category_positions(@category.parent_id, category_params[:position])
      @category.update_attributes(category_params)
      if @category.save
        render json: @category
      else
        head :unprocessable_entity
        raise ActiveRecord::Rollback
      end
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

  def categories_at_or_after(parent_id, position)
    Category.where(parent_id: parent_id).where('position >= ?', position)
  end

  def decrement_category_positions(parent_id, start_position)
    # decrement the position for every category at or after the given positio
    categories_at_or_after(parent_id, start_position).update_all('position = position - 1')
  end

  def increment_category_positions(parent_id, start_position)
    # increment the position for every category at or after the given position
    categories_at_or_after(parent_id, start_position).update_all('position = position + 1')
  end
end
