class Member < ActiveRecord::Base
  belongs_to :tenant
  acts_as_tenant :tenant
  belongs_to :user
  DEFAULT_ADMIN={
    first_name: 'Admin',
    last_name: 'Please edit me',
  }
  def self.create_new_member(user, member_params)
    new_member = user.create_member(member_params);
    return new_member
  end
  def self.create_org_admin(user)
    new_member = create_new_member(user, DEFAULT_ADMIN)
    unless new_member.errors.empty?
      raise StandardError, "Error creating organization admin member: #{new_member.errors.full_messages.to_sentence}"
    end
    return new_member
  end
end 