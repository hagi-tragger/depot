# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '21fa325cadd3d2bfdb62e7990c6811c53f92c15e1bcf0e124f6bd8f6690d53de3c95131c18bdb36a0bfdc31a1f5d001817999e36c24174aa2beb5a94fa2d52f4'
  
  private 
	
	def authorize
		unless User.find_by_id(session[:user_id])
			session[:original_uri] = request.request_uri
			flash[:notice] = "Please log in"
			redirect_to(:controller => "login", :action => "login")
		end
	end
end
