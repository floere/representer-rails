class CartController < ApplicationController
  
  def index
    
    @items = [
      Book.new(36),
      Book.new(45),
      HumanHead.new(30)
    ]
    
  end
  
end