# frozen_string_literal: true

class API::V2::CategoryProcessor < JSONAPI::Processor
  before_remove_resource do
    raise Forbidden unless @context[:current_user]
  end

  before_create_resource do
    raise Forbidden unless @context[:current_user]
  end

  before_replace_fields do
    raise Forbidden unless @context[:current_user]
  end
end
