class ApplicationController < ActionController::Base
  # 1. Devise setup
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?
  
  # 2. Multi-tenancy setup (ActsAsTenant)
  set_current_tenant_through_filter
  before_action :set_tenant

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      tenant_attributes: [:name, :plan]
    ])
  end

  def set_tenant
    # Skip tenant setup for devise (login/signup) or if no user is signed in yet
    return if devise_controller? || !user_signed_in?

    # Find the tenant directly from the current user
    # This assumes your User model has 'belongs_to :tenant'
    tenant = current_user.tenant

    if tenant
      # Set the global scope for ActsAsTenant
      set_current_tenant(tenant)
      
      # Set instance variables for use in controllers/views
      @current_tenant = tenant
      
      # Optional: set current member if you have a Member join model
      # @current_member = current_user.member_for_tenant(tenant)
    else
      # Handle cases where a user somehow exists without a tenant
      redirect_to root_path, alert: "Please join an organization to continue." unless devise_controller?
    end
  end

  # Make these available in views as helper methods
  helper_method :current_tenant

  def current_tenant
    @current_tenant || current_user&.tenant
  end
end