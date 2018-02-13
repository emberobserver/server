# frozen_string_literal: true

class API::V2::ReviewProcessor < JSONAPI::Processor
  before_remove_resource do
    raise Forbidden
  end

  before_create_resource do
    raise Forbidden unless @context[:current_user]
  end

  before_replace_fields do
    raise Forbidden
  end
end
