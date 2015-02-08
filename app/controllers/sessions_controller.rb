class SessionsController < ApplicationController
  def index
    @user = User.new
  end
  
  def create
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
    end
    redirect_to profile_path
  end
end
