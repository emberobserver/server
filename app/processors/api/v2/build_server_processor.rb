# frozen_string_literal: true

class API::V2::BuildServerProcessor < JSONAPI::Processor
  before_operation do
    raise Forbidden unless @context[:current_user]
  end
end
