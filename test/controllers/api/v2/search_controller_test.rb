require 'test_helper'

class API::V2::SearchControllerTest < ControllerTest

  test 'returns search results' do
    create :addon, readme: (create :readme, contents: 'test booo happy Beef ribs pork chop rump capicola
. Tenderloin capicola beef ribs spare ribs, brisket pork chop pork belly frankfurter jerky bresaola sirloin ball tip. Meatball shank short ribs venison. Biltong chicken ribeye, andouille short ribs ham hock sirloin drumstick pastrami cow prosciutto beef landjaeger pancetta. dodo dod oo dooo do helps to speed
 up tests and blah')
    create :addon, readme: (create :readme, contents: 'please submit test cases with pull requests')
    create :addon, readme: (create :readme, contents: 'this is an addon for testing things')

    ReadmeView.refresh

    get :search, query: 'test'

    results = JSON.parse(response.body)['search']
    assert_equal(3, results.size)

    first_result = results.first
    assert_equal(1, first_result['matches'].size)
    assert first_result['matches'].first =~ /<b>test<\/b>/

    last_result = results.last
    assert_equal(1, last_result['matches'].size)
    assert last_result['matches'].first =~ /<b>testing<\/b>/
  end

  test 'addon search returns empty results if no query' do
    get :addons, query: ''

    assert_response :ok
    assert_equal 0, json_response['results'].size
  end

  test 'source search returns empty results if no query' do
    get :source, query: '', addon: 'ember-foo'

    assert_response :ok
    assert_equal 0, json_response['results'].size
  end

end
