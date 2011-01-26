class AdminController < ApplicationController
	
	before_filter :authorize
	
	def index
		list
	end
	
	def list
		@products = Product.paginate :page => params[:page] || 1, :per_page => 10
	end
end
