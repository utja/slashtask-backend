class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    # returns the jwt string
    JWT.encode(payload, ENV["my_precious_jwt"])
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      # header: { 'Authorization': 'Bearer <token>' }
      begin
        JWT.decode(token, ENV["my_precious_jwt"], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

    def current_user
      if decoded_token
        # decoded_token=> [{"user_id"=>__ }, {"alg"=>"HS256"}]
        # or nil if we can't decode the token
        user_id = decoded_token[0]['user_id']
        @user = User.find_by(id: user_id)
      end
    end

    def logged_in?
      !!current_user
    end

    def authorized
      render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
    end

end
