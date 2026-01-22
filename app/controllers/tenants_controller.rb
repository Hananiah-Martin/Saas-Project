class TenantsController < ApplicationController
  def members
    @tenant = Tenant.find(params[:id])
    @member =Member.new
    # @members = @tenant.users # Or however you define members
    # This will render app/views/tenants/members.html.erb
  end
  def invite_member
    @tenant = Tenant.find(params[:id])
    email = params[:user][:email]
    User.invite!({ email: email, tenant_id: @tenant.id }, current_user)
    redirect_to members_tenant_path(@tenant), notice: "Invitation sent!"
  end
end