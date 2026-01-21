class Tenant < ActiveRecord::Base

    has_many :members, dependent: :destroy
    validates_uniqueness_of :name
    validates_presence_of :name
    has_many :projects, dependent: :destroy
    def self.create_new_tenant(tenant_params, user_params, coupon_params)

      tenant = Tenant.new(tenant_params)

      if new_signups_not_permitted?(coupon_params)

        raise raise StandardError, "Sorry, new accounts not permitted at this time"  

      else 
        tenant.save    # create the tenant
      end
      return tenant
    end

  # ------------------------------------------------------------------------
  # new_signups_not_permitted? -- returns true if no further signups allowed
  # args: params from user input; might contain a special 'coupon' code
  #       used to determine whether or not to allow another signup
  # ------------------------------------------------------------------------
  def self.new_signups_not_permitted?(params)
    return false
  end

  
    def self.tenant_signup(user, tenant, other = nil)
      Member.create_org_admin(user)
    end

   
end