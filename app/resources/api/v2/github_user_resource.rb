class API::V2::GithubUserResource < JSONAPI::Resource
  attributes :name, :avatar_url

  def name
    @model.login
  end
end
