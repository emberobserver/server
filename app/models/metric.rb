class API::Metric < ActiveRecord::Base
  has_many :evaluations
end
