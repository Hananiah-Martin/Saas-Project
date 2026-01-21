class MembersController < ApplicationController
  def new
    @member = Member.new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save_and_invite_member() && @user.create_member(member_params)
      redirect_to root_path, notice: "Member invited successfully."
    else
      flash[:error] = "Failed to invite member."
      @member = Member.new(member_params)
      render :new
    end
  end

  def member_params()
    params.require(:member).permit(:first_name, :last_name, :role)
  end

  def user_params()
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end