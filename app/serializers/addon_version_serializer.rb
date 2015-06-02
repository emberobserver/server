class AddonVersionSerializer < ApplicationSerializer
	attributes :id, :version, :released, :addon_id, :ember_cli_version
  has_one :review
end
