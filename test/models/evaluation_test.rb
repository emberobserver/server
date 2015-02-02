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

require 'test_helper'

class EvaluationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
