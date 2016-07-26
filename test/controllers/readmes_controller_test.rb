require 'test_helper'

class ReadmesControllerTest < ControllerTest

  test 'show returns the readme' do
    addon = create :addon
    readme = Readme.create(contents: 'README contents', addon: addon)

    get :show, id: readme.id

    response = json_response['readme']
    assert_equal readme.id, response['id']
    assert_equal readme.contents, response['contents']
  end

end
