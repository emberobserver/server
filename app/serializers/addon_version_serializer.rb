class AddonVersionSerializer < ApplicationSerializer
	attributes :id, :version, :released, :addon_id
  has_one :review
end
