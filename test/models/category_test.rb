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

  test "converts a position of -1 to the last position when saving" do
    last_position = categories(:last).position
    category = Category.create(name: 'new category', position: -1)
    assert_equal last_position + 1, category.position
  end
end
