# == Schema Information
#
# Table name: packages
#
#  id                  :integer          not null, primary key
#  name                :string
#  repository_url      :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  latest_version      :string
#  description         :string
#  license             :string
#  author_id           :integer
#  latest_version_date :datetime
#

require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
