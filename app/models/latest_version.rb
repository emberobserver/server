class LatestVersion < ActiveRecord::Base
	validates :package, uniqueness: true
end
