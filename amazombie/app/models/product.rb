class Product
  attr_accessor :price, :description
  
  def description
    'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
  end
  
  def textile_description
    'Lorem *ipsum* dolor sit amet, "consectetur":http://rails-konferenz.de adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
  end
  
end