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
      Category.create! description: 'some description', position: 1
    end
  end

  test "position is required" do
    assert_raises ActiveRecord::RecordInvalid do
      Category.create! name: 'new category'
    end
  end

  test "position should be unique for top-level categories" do
    assert_raises ActiveRecord::RecordInvalid do
      Category.create! name: 'new category', position: 1
    end
  end

  test "duplicate positions should be allowed across parent categories" do
    assert_nothing_raised ActiveRecord::RecordInvalid do
      Category.create! name: 'new category', position: 1, parent_category: categories(:first)
    end
  end

  test "converts a position of -1 to the last position when saving" do
    last_position = categories(:last).position
    category = Category.create(name: 'new category', position: -1)
    assert_equal last_position + 1, category.position
  end

  test "converts a position of -1 for a subcategory to the last position among the other siblings" do
    last_position = categories(:subcategory).position
    category = categories(:parent).subcategories.create(name: 'new subcategory', position: -1)
    assert_equal last_position + 1, category.position
  end
end
