class PackageVersionSerializer < ApplicationSerializer
	attributes :id, :version, :released
	has_one :review, include_in_root: true
end
