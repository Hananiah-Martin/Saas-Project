class MemberMailer < ApplicationMailer
  def invitation_email(email, tenant, first_name)
    @tenant = tenant
    @first_name = first_name
    @url = new_user_registration_url(tenant_id: @tenant.id, plan: 'free', host: 'localhost:3000') 
  
    mail(to: email, subject: "Invitation to join #{@tenant.name}")
  end
endpro