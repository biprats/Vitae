class SessionsController < ApplicationController
  def create
    @user = User.find_by(email: params[:User][:email])
    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
    end
    redirect_to users_path
  end
end
