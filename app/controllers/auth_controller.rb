class AuthController < ApplicationController

  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      user.set_auth_token!
      render json: { token: user.auth_token }.to_json
    else
      user.clear_auth_token! if user
      render json: { error: "Invalid login details" }.to_json, status: 401
    end
  end

  def logout
    user = authenticate_user_token
    user.clear_auth_token! if user
    render json: {}, status: 200
  end
end
