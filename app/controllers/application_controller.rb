class ApplicationController < ActionController::Base
  skip_before_filter :verify_authenticity_token  
  protect_from_forgery with: :exception
end
