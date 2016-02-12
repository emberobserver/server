require 'test_helper'

class KeywordsControllerTest < ControllerTest

  test 'can fetch all keywords' do
    create_list :npm_keyword, 5

    get :index

    assert_response 200
    assert_equal 5, json_response['keywords'].size
  end

  test 'can fetch keywords for a given addon' do
    addon = create :addon
    addon.npm_keywords << create_list(:npm_keyword, 2)

    create_list :npm_keyword, 5

    get :index, addon_id: addon.id

    assert_response 200
    assert_equal 2, json_response['keywords'].size
  end

  test 'can fetch a single keyword' do
    keyword = create :npm_keyword, keyword: 'testing'

    get :show, id: keyword.id

    assert_response 200
    assert_equal 'testing', json_response['npm_keyword']['keyword']
  end

end
