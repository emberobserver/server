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
end
