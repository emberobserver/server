class EvaluationSerializer < ActiveModel::Serializer
  attributes :id, :score
  has_one :metric
  has_one :review
end
