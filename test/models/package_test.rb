# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  name           :string
#  npmjs_url      :string
#  github_url     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  latest_version :string
#  description    :string
#

require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
