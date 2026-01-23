# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  # raise: false prevents errors if these methods aren't in the inheritance chain yet
  skip_before_action :set_tenant, only: [:new, :create], raise: false
  skip_before_action :authenticate_user!, only: [:new, :create], raise: false

  def new
    build_resource({})
    resource.build_tenant # Ensures the "Organization Details" fields appear
    respond_with self.resource
  end

  def create
    tenant_params = sign_up_params[:tenant_attributes] || {}
    
    ActiveRecord::Base.transaction do
      # 1. Initialize Tenant (No subdomain needed)
      @tenant = Tenant.new(name: tenant_params[:name], plan: tenant_params[:plan])
      
      if @tenant.save
        # 2. Build User and link the Tenant
        build_resource(sign_up_params.except(:tenant_attributes))
        resource.tenant = @tenant
        
        if resource.save
          # 3. Handle Membership/Roles within the tenant scope
          ActsAsTenant.with_tenant(@tenant) do
            Member.create_org_admin(resource)
          end
          
          # 4. Finalize session and redirect to standard root path
          yield resource if block_given?
          if resource.active_for_authentication?
            set_flash_message! :notice, :signed_up
            sign_up(resource_name, resource)
            redirect_to after_sign_up_path_for(resource) and return
          else
            set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
            expire_data_after_sign_in!
            redirect_to after_inactive_sign_up_path_for(resource) and return
          end
        else
          # Rollback if User fails
          raise ActiveRecord::Rollback
        end
      else
        # Rollback if Tenant fails
        raise ActiveRecord::Rollback
      end
    end
    
    # This code runs if the transaction was rolled back
    clean_up_passwords resource
    set_minimum_password_length
    # Add tenant errors to the resource so they show up in the UI
    resource.errors.add(:base, @tenant.errors.full_messages.to_sentence) if @tenant&.errors&.any?
    render :new, status: :unprocessable_entity
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email, 
      :password, 
      :password_confirmation,
      tenant_attributes: [:name, :plan]
    )
  end
end