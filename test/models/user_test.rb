# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  password_digest :string
#  auth_token      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "can clear the auth token" do
    user = create :user, auth_token: 'something'
    user.clear_auth_token!

    assert_nil user.reload.auth_token
  end

  test "can set an auth token" do
    user = create :user, auth_token: nil
    user.set_auth_token!

    assert_not_nil user.reload.auth_token
  end
end
