# frozen_string_literal: true

class API::V2::GithubUserResource < JSONAPI::Resource
  immutable
  attributes :name, :avatar_url

  def name
    @model.login
  end
end
