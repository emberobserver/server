# frozen_string_literal: true

require 'test_helper'

class BadgeGeneratorTest < ActiveSupport::TestCase
  test 'addon_badge_path' do
    addon = create(:addon, name: '@thing/whoa')

    generator = create_generator(addon)

    assert_equal(generator.addon_badge_path, Rails.root.join('public/badges/-thing-whoa.svg').to_s)
  end

  test 'template_badge_path with integer score' do
    addon = create(:addon, score: 8)

    generator = create_generator(addon)

    assert_equal(generator.template_badge_path, Rails.root.join('app/assets/images/badges/8.0.svg'))
  end

  test 'template_badge_path with decimal score' do
    addon = create(:addon, score: 8.59)

    generator = create_generator(addon)

    assert_equal(generator.template_badge_path, Rails.root.join('app/assets/images/badges/8.6.svg'))
  end

  private

  def create_generator(addon)
    BadgeGenerator.new(addon)
  end
end
