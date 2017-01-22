class API::V2::EmberVersionCompatibilityResource < JSONAPI::Resource
  immutable
  attributes :ember_version, :compatible
end
