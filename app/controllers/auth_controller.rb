class AuthController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create
    render json: { token: 'abcd' }.to_json
  end
end
