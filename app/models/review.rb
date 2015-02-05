class Review < ActiveRecord::Base
	belongs_to :package_version
end
