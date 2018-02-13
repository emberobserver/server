# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_versions
#
#  id                :integer          not null, primary key
#  addon_id          :integer
#  version           :string
#  released          :datetime
#  addon_name        :string
#  ember_cli_version :string
#
# Indexes
#
#  index_addon_versions_on_addon_id  (addon_id)
#

require 'test_helper'

class AddonVersionTest < ActiveSupport::TestCase
  test 'uses the most recent review for a version' do
    addon_version = create :addon_version, :basic_one_point_one

    travel_to 1.day.ago do
      Review.create!(addon_version_id: addon_version.id, review: 'older')
    end
    Review.create!(addon_version_id: addon_version.id, review: 'newer')

    assert_equal 'newer', addon_version.review.review
  end
end
