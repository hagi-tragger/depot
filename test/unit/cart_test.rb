require File.dirname(__FILE__) + '/../test_helper'

class CartTest < ActiveSupport::TestCase

	fixtures :products
	
	def setup
		@cart = Cart.new
		@rails_book = products(:rails_book)
		@ruby_book = products(:ruby_book)
	end
	
	def test_add_unique_products		
		@cart.add_product @rails_book
		@cart.add_product @ruby_book
		assert_equal 2, @cart.items.size
		assert_equal @rails_book.price + @ruby_book.price, @cart.total_price
	end
	
	def test_add_duplicate_products
		@cart.add_product @rails_book
		@cart.add_product @rails_book
		assert_equal 1, @cart.items.size
		assert_equal 2*@rails_book.price, @cart.total_price
		assert_equal 2, @cart.items[0].quantity
	end
	
end