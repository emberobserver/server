# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  parent_id   :integer
#  position    :integer
#

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test "name is required" do
    assert_raises ActiveRecord::RecordInvalid do
      Category.create! description: 'some description'
    end
  end

  test "position should be unique for top-level categories" do
    category = create :category
    assert_raises ActiveRecord::RecordInvalid do
      Category.create! name: 'new category', position: category.position
    end
  end

  test "duplicate positions should be allowed across parent categories" do
    assert_nothing_raised ActiveRecord::RecordInvalid do
      Category.create! name: 'new category', position: 1, parent_category: create(:category)
    end
  end

  test "converts a position of -1 to the last position when saving" do
    create_list :category, 4
    last_position = Category.last.position

    category = Category.create!(name: 'new category', position: -1)
    assert_equal last_position + 1, category.reload.position
  end

  test "converts a position of -1 for a subcategory to the last position among the other siblings" do
    subcategory = create :subcategory
    parent = subcategory.parent_category
    last_position = subcategory.position

    category = parent.subcategories.create!(name: 'new subcategory', position: -1)
    assert_equal last_position + 1, category.reload.position
  end

  test "automatically sets position of a category when created with nil" do
    last_position = create(:category).position
    category = Category.create!(name: 'new category')
    assert_equal last_position + 1, category.position
  end

  test "cannot have itself as a parent" do
    category = Category.create!(name: 'new category')
    assert_raises ActiveRecord::RecordInvalid do
      category.parent_id = category.id
      category.save!
    end
  end

  test "correctly sets position when making the category the first child of a parent" do
    category = create(:category).subcategories.create!(name: 'new subcategory')
    assert_equal 1, category.position
  end
end
