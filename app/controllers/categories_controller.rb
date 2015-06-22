class CategoriesController < ApplicationController
  before_action :authenticate, only: [:create, :update]

  def index
    render_cached_json 'api:categories:index' do
      categories = Category.includes(:addons)
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
      category = Category.find(params[:id])
    rescue
      head :not_found
      return
    end

    Category.transaction do
      category.update_attributes(basic_category_params)

      if parent_id_param != category.parent_id
        move_category_to_new_parent(category, parent_id_param)
      elsif position_param != category.position
        move_category_to_new_position(category, position_param)
      end

      if category.save
        render json: category
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
    params.require(:category).permit(:name, :description, :parent_id, :position)
  end

  def basic_category_params
    params.require(:category).permit(:name, :description)
  end

  def parent_id_param
    params[:category][:parent_id] ? params[:category][:parent_id].to_i : nil
  end

  def position_param
    params[:category][:position] ? params[:category][:position].to_i : nil
  end

  def categories_at_or_after(parent_id, position)
    Category.where(parent_id: parent_id).where('position >= ?', position)
  end

  def decrement_category_positions(parent_id, start_position)
    # decrement the position for every category at or after the given position
    categories_at_or_after(parent_id, start_position).update_all('position = position - 1')
  end

  def increment_category_positions(parent_id, start_position)
    # increment the position for every category at or after the given position
    categories_at_or_after(parent_id, start_position).update_all('position = position + 1')
  end

  def move_category_to_new_parent(category, new_parent_id)
    original_parent_id = category.parent_id
    original_position = category.position

    category.parent_id = new_parent_id
    category.position = -1

    # Update the positions for following categories in the old parent
    decrement_category_positions(original_parent_id, original_position)
  end

  def move_category_to_new_position(category, position)
    original_position = category.position

    # First move the target category to the end
    category.position = -1
    category.save

    # Update the positions for categories that came after the target category
    decrement_category_positions(category.parent_id, original_position)
    # Now make room for the target category
    if position && position != -1
      increment_category_positions(category.parent_id, position)
      category.position = position
    end
  end
end
