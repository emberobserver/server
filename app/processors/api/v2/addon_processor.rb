class API::V2::AddonProcessor < JSONAPI::Processor

  before_remove_resource do
    raise Forbidden
  end

  before_create_resource do
    raise Forbidden
  end

  before_replace_fields do
    raise Forbidden unless @context[:current_user]
  end
end
