class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # Defaultne jsou helpery ve vsech view, ale ne v controllerech
  include SessionsHelper
end
