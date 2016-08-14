class FullTestResultSerializer < ApplicationSerializer
  self.root = :test_result
  attributes :id, :succeeded, :status_message, :tests_run_at, :semver_string, :stdout, :stderr
  has_many :ember_version_compatibilities
  has_one :version

  def version
    object.addon_version
  end

  def tests_run_at
    object.created_at
  end
end
