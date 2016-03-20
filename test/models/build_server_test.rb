# == Schema Information
#
# Table name: build_servers
#
#  id         :integer          not null, primary key
#  name       :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class BuildServerTest < ActiveSupport::TestCase
  test "requires a unique name" do
    assert_raises ActiveRecord::RecordInvalid do
      BuildServer.create!
    end

    build_server = create(:build_server)
    assert_raises ActiveRecord::RecordInvalid do
      BuildServer.create!(name: build_server.name)
    end
  end
  test "generates a token when creating" do
    build_server = BuildServer.create(name: 'build server')
    assert_not_nil build_server.token
  end
end
