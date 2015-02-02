# == Schema Information
#
# Table name: category_packages
#
#  id          :integer          not null, primary key
#  category_id :integer
#  package_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class CategoryPackageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
