require "#{File.dirname(__FILE__)}/../test_helper"

class UserStoriesTest < ActionController::IntegrationTest
  # fixtures :your, :models
  fixtures :products
  fixtures :users
  
  DAVES_DETAILS = {
	:name 		=> "Dave Thomas",
	:address 	=> "123 The Street",
	:email 		=> "dave@pragprog.com",
	:pay_type 	=> "check"
  }

  MIKES_DETAILS = {
	:name 		=> "Mike Clark",
	:address 	=> "345 The Avenue",
	:email 		=> "mikee@pragmaticstudio.com",
	:pay_type 	=> "cc"
  }

  def setup
	LineItem.delete_all
	Order.delete_all
	@ruby_book = products(:ruby_book)
	@rails_book = products(:rails_book)
  end
  
  def test_buying_a_product
	LineItem.delete_all
	Order.delete_all
	ruby_book = products(:ruby_book)
	
	get "/store/index"
	assert_response :success
	assert_template "index"
	
	xml_http_request :post, "/store/add_to_cart", { :id => ruby_book.id }
	assert_response :success
	cart = session[:cart]
	assert_equal 1, cart.items.size
	assert_equal ruby_book, cart.items[0].product
	
	post "/store/checkout"
	assert_response :success
	assert_template "checkout"
	
	post_via_redirect "/store/save_order",
		:order => { :name => "Dave Thomas",
					:address => "123 The Street",
					:email => "dave@pragprog.com",
					:pay_type => "check"
				  }
	assert_response :success
	assert_template "index"
	assert_equal 0, session[:cart].items.size
	
	orders = Order.find(:all)
	assert_equal 1, orders.size
	order = orders[0]
	assert_equal "Dave Thomas", order.name
	assert_equal "123 The Street", order.address
	assert_equal "dave@pragprog.com", order.email
	assert_equal "check", order.pay_type
	
	assert_equal 1, order.line_items.size
	line_item = order.line_items[0]
	assert_equal ruby_book, line_item.product
  end
  
  def test_one_man_buying
	dave = regular_user
	dave.get "/store/index"
	dave.is_viewing "index"
	dave.buys_a @ruby_book
	dave.has_a_cart_containing @ruby_book
	dave.checks_out DAVES_DETAILS
	dave.is_viewing "index"
	check_for_order DAVES_DETAILS, @ruby_book
  end
  
  def test_two_people_buying
	dave = regular_user
		mike = regular_user
	dave.buys_a @ruby_book
		mike.buys_a @rails_book
	dave.has_a_cart_containing @ruby_book
		mike.has_a_cart_containing @rails_book
	dave.checks_out DAVES_DETAILS
		mike.checks_out MIKES_DETAILS
	check_for_order DAVES_DETAILS, @ruby_book
		check_for_order MIKES_DETAILS, @rails_book
  end
  
  def regular_user
	open_session do |user|
		def user.is_viewing(page)
			assert_response :success
			assert_template page
		end
		
		def user.buys_a(product)
			xml_http_request :post, "/store/add_to_cart", :id => product.id
			assert_response :success
		end
		
		def user.has_a_cart_containing(*products)
			cart = session[:cart]
			assert_equal products.size, cart.items.size
			for item in cart.items
				assert products.include?(item.product)
			end
		end
		
		def user.checks_out(details)
			post "/store/checkout"
			assert_response :success
			assert_template "checkout"
			
			post_via_redirect "/store/save_order",
				:order => { :name => details[:name],
							:address => details[:address],
							:email => details[:email],
							:pay_type => details[:pay_type]
						  }
			assert_response :success
			assert_template "index"
			assert_equal 0, session[:cart].items.size
		end
	end
  end
	
  def check_for_order(details, *products)
	order = Order.find_by_name(details[:name])
	assert_not_nil order
	
	assert_equal details[:name], order.name
	assert_equal details[:address], order.address
	assert_equal details[:email], order.email
	assert_equal details[:pay_type], order.pay_type
	
	assert_equal products.size, order.line_items.size
	for line_item in order.line_items
		assert products.include?(line_item.product)
	end
  end
end
