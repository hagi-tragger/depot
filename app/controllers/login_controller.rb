class LoginController < ApplicationController
  before_filter :authorize, :except => :login
  layout "admin"
  def add_user
	@user = User.new(params[:user])
	if request.post? and @user.save
		flash.now[:notice] = "User #{@user.name} created"
		@user = User.new
	end
  end

  def login
	session[:user_id] = nil
	if request.post?
		# первая авторизация под любым именем
		if User.count == 0
			User.create(:name => params[:name], :password => params[:password], :password_confirmation => params[:password])
		end
		user = User.authenticate(params[:name], params[:password])
		if user
			session[:user_id] = user.id
			uri = session[:original_uri]
			session[:original_uri] = nil
			redirect_to(uri || {:action => "index"})
		else
			flash[:notice] = "Wrong combination login-password"
		end
	end
  end

  def logout
	session[:user_id] = nil
	flash[:notice] = "Logged out"
	redirect_to(:action => "login")
  end

  def index
	@total_orders = Order.count
  end

  def delete_user
	if request.post?
		user = User.find(params[:id])
		user.destroy
	end
	redirect_to(:action => :list_users)
  end

  def list_users
	@all_users = User.find(:all)
  end
end
