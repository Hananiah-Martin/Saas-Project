class MembersController < ApplicationController
  def new
    @member = Member.new
    @user = User.new
  end

  def create
    user_email = params[:user][:email]
    
    ActiveRecord::Base.transaction do
      # 1. Invite the user and link them to the current organization
      # This sends the email automatically
      @user = User.invite!({ email: user_email, tenant: current_tenant }, current_user)

      # 2. Create the Member profile linked to that user
      @member = Member.new(member_params)
      @member.user = @user
      @member.tenant = current_tenant

      if @member.save
        redirect_to root_path, notice: "Invitation sent to #{user_email}!"
      else
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::Rollback
    render :new, status: :unprocessable_entity
  end

  def member_params
    params.require(:member).permit(:first_name, :last_name)
  end

  def user_params()
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end