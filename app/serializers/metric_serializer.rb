class MetricSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :details
end
