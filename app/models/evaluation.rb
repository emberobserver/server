class Evaluation < ActiveRecord::Base
  belongs_to :metric
  belongs_to :review
end
