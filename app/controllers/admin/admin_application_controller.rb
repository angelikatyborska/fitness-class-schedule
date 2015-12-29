class Admin::AdminApplicationController < ApplicationController
  before_action :authenticate_admin!

  protected

  def authenticate_admin!
    return true if user_signed_in? && current_user.admin?
    not_found
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
