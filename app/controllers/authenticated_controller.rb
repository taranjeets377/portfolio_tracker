# Base controller for authenticated routes.
class AuthenticatedController < ApplicationController
  before_action :authenticate_user!

  def after_sign_in_path_for(_resource)
    dashboard_index_path
  end
end
