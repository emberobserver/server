class API::Review < ActiveRecord::Base
  belongs_to :package
  has_many :evaluations
end
