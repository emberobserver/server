class PackageVersion < ActiveRecord::Base
	belongs_to :package
	has_one :review
end
