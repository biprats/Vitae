class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to profile_path
    end
  end

  def update
    current_user.update(resume: params[:user][:resume])
    redirect_to profile_path
  end

  def show
    @user = User.find_by(id: params[:id])
    unless @user
      redirect_to root_path
    end
  end

  def profile
    unless current_user
      redirect_to root_path
    end
  end
  
  def upload
    AWS.config(
      access_key_id: ENV["AWS_PUBLIC"],
      secret_access_key: ENV["AWS_SECRET"],
      region: "us-east-1"
    )
    s3 = AWS::S3.new
    s3.buckets["vitae"].objects["users/#{current_user.id}/original.jpg"].write(file: params[:user][:image])

    current_user.update(image: "https://s3.amazonaws.com/vitae/users/#{current_user.id}/original.jpg")
    redirect_to profile_path
  end

  private
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end
end
