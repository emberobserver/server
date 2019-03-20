# frozen_string_literal: true

require 'test_helper'

class API::V2::AutocompleteControllerTest < ActionController::TestCase
  test 'hidden addons are not included' do
    create :addon
    hidden_addon = create(:addon, :hidden)

    assert_not_includes autocomplete_addon_names, hidden_addon.name
  end

  test 'addons that are removed_from_npm are not included' do
    create :addon
    removed_addon = create(:addon, removed_from_npm: true)

    assert_not_includes autocomplete_addon_names, removed_addon.name
  end

  test 'addons that are WIP are included' do
    create :addon
    wip_addon = create(:addon, is_wip: true)

    assert_includes autocomplete_addon_names, wip_addon.name
  end

  private

  def autocomplete_addon_names
    get :data

    JSON.parse(response.body)['addons'].map { |a| a['name'] }
  end
end
