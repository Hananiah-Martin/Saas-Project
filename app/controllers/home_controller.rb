class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    if user_signed_in?
      @projects=Project.visible_by_plan
    end
  end
end
