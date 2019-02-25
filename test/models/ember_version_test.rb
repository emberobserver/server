# == Schema Information
#
# Table name: ember_versions
#
#  id         :integer          not null, primary key
#  version    :string           not null
#  released   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class EmberVersionTest < ActiveSupport::TestCase
  test '#beta? returns true when version contains "beta"' do
    ember_version = EmberVersion.new(version: '3.9.0-beta.1')

    assert_equal true, ember_version.beta?
  end

  test '#beta? returns false when version does not contain "beta"' do
    ember_version = EmberVersion.new(version: '3.8.0')

    assert_equal false, ember_version.beta?
  end

  test '#major_or_minor? returns true when version ends in .0' do
    ember_version = EmberVersion.new(version: '3.8.0')

    assert_equal true, ember_version.major_or_minor?
  end

  test '#major_or_minor? returns false when version does not end in .0' do
    ember_version = EmberVersion.new(version: '3.8.1')

    assert_equal false, ember_version.major_or_minor?
  end

  test '#major_or_minor? returns false when version contains .0 in the middle' do
    ember_version = EmberVersion.new(version: '4.0.1')

    assert_equal false, ember_version.major_or_minor?
  end
end
