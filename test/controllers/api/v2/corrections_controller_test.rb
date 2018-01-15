require 'test_helper'

class API::V2::CorrectionsControllerTest < ControllerTest

  setup do
    CorrectionMailer.deliveries = []
  end

  test 'can submit a correction' do
    create :addon, name: 'blah'

    post :submit, params: { name: '', email: '', addon: 'blah', correction: '' }

    assert_response :no_content
    assert_equal 1, CorrectionMailer.deliveries.size
  end

  test 'cannot submit a correction with nonexistent addon' do
    create :addon, name: 'blah'

    post :submit, params: { name: '', email: '', addon: 'blerg', correction: '' }

    assert_response :unprocessable_entity
    assert_equal 0, CorrectionMailer.deliveries.size
  end

end
