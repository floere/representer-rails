class Product
  attr_accessor :price
  
  def initialize
    @price = 19 + rand(20)
  end
  
end