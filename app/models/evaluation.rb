# == Schema Information
#
# Table name: evaluations
#
#  id         :integer          not null, primary key
#  metric_id  :integer
#  review_id  :integer
#  score      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Evaluation < ActiveRecord::Base
  belongs_to :metric
  belongs_to :review
end
