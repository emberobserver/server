# frozen_string_literal: true

class API::V2::CategoryResource < JSONAPI::Resource
  attributes :name, :description, :position, :addon_count
  has_many :subcategories, class_name: 'Category'
  has_one :parent, class_name: 'Category', relation_name: 'parent_category'

  has_many :addons

  def addon_count
    @model.addons.count
  end

  def position=(new_position)
    if new_position != -1
      Category.transaction do
        move_category_to_new_position(@model, new_position)
      end
    end
    @model.position = new_position
  end

  def self.updatable_fields(context)
    return [] unless context[:current_user]
    super - [:addon_count]
  end

  def self.creatable_fields(context)
    return [] unless context[:current_user]
    super - [:addon_count]
  end

  private

  def move_category_to_new_position(category, new_position)
    original_position = category.position

    if category.persisted?
      # First move the target category to the end
      category.position = -1
      category.save
    end

    if original_position
      # Update the positions for categories that came after the target category
      decrement_category_positions(category.parent_id, original_position)
    end

    # Now make room for the target category
    if new_position && new_position != -1 # rubocop:disable Style/GuardClause
      increment_category_positions(category.parent_id, new_position)
    end
  end

  def decrement_category_positions(parent_id, start_position)
    # decrement the position for every category at or after the given position
    # rubocop:disable Rails/SkipsModelValidations
    categories_at_or_after(parent_id, start_position).update_all('position = position - 1')
    # rubocop:enable Rails/SkipsModelValidations
  end

  def increment_category_positions(parent_id, start_position)
    # increment the position for every category at or after the given position
    # rubocop:disable Rails/SkipsModelValidations
    categories_at_or_after(parent_id, start_position).update_all('position = position + 1')
    # rubocop:enable Rails/SkipsModelValidations
  end

  def categories_at_or_after(parent_id, position)
    Category.where(parent_id: parent_id).where('position >= ?', position)
  end
end
