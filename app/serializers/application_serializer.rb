# frozen_string_literal: true

class ApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true
end
