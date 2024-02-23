class Api::TestController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate_request

  def test
    render json: { message: 'Hello World' }
  end

  private

  def authenticate_request
    authenticate_or_request_with_http_token do |token, _options|
      token == 'MMgCEy7JbCnBLrGmgRrc'
    end
  end
end
