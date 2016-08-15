# == Schema Information
#
# Table name: test_results
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  succeeded        :boolean
#  status_message   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  canary           :boolean          default(FALSE), not null
#  build_server_id  :integer
#  semver_string    :string
#  stdout           :text
#  stderr           :text
#

class TestResultSerializer < ApplicationSerializer
  attributes :id, :succeeded, :status_message, :tests_run_at, :semver_string, :canary
  has_many :ember_version_compatibilities
  has_one :version

  def version
    object.addon_version
  end

  def tests_run_at
    object.created_at
  end
end
