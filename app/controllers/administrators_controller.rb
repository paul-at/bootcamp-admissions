class AdministratorsController < ApplicationController
  before_action do |controller|
    @settings_page = true
  end

  def index
    @users = User.all
    authorize! :manage, User
  end

  def update
    @user = User.find_by_id(params[:id])
    authorize! :manage, @user

    ['staff', 'admin'].each do |role|
      next unless params[role]
      @user.update_attribute(role, params[role] == 'true')
    end
  end
end
