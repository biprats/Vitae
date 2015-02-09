class SessionsController < ApplicationController
  def index
    @user = User.new
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def create
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      redirect_to profile_path
    else
      redirect_to sessions_path
    end
  end
end
