require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_invalid_with_empty_attributes
	product = Product.new
	assert !product.valid?
	assert product.errors.invalid?(:title)
	assert product.errors.invalid?(:description)
	assert product.errors.invalid?(:price)
	assert product.errors.invalid?(:image_url)
  end
  
  def test_image_url
	ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
	bad = %w{ fred.doc fred.gif/more fred.gif.more }
	ok.each do |name|
		product = Product.new(	:title => "Some book name",
								:description => "aaa",
								:price => 1,
								:image_url => name)
		assert product.valid?, product.errors.full_messages
	end
	bad.each do |name|
		product = Product.new(	:title => "Some book name",
								:description => "aaa",
								:price => 1,
								:image_url => name)
		assert product.valid?, "saving #{name}"
	end
  end
  
  def test_unique_title
	product = Product.new(	:title => products(:ruby_book).title,
							:description => "yyy",
							:price => 2,
							:image_url => "fred.gif")
	assert !product.save
	assert_equal "That name was already used: ", product.errors.on(:title)
  end
end
