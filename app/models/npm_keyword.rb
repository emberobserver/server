class NpmKeyword < ActiveRecord::Base
	has_and_belongs_to_many :packages, join_table: 'package_npm_keywords'
end
