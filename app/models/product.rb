class Product < ActiveRecord::Base

	has_many :line_items
	has_many :orders, :through => :line_items
	
	def self.find_products_for_sale
		find(:all, :order => "title")
	end
	
	validates_presence_of :title, :description, :image_url
	validates_numericality_of :price
	validates_uniqueness_of :title
	validates_format_of :image_url,
			:with => %r{\.(gif|jpg|png)$}i,
			:message => "URL должен указывать на изображение формата GIF, JPG или PNG"
			
	protected
	
	def validate 
		errors.add(:price, "должна быть не менее 0.01") if price.nil? || price < 0.01
	end
	
end
