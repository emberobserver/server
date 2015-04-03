class AddPositionToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :position, :integer
    component_cat = Category.where(name: 'Components').first
    if component_cat
      component_cat.position = 5
      component_cat.save
    end

    position = 1
    Category.where(position: nil).each do |category|
      category.position = position
      category.save
      position = position + 1
      position = position + 1 if position == 5
    end
  end
end
