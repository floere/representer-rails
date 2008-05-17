class CartController < ApplicationController
  
  def index
    
    @items = [
      Book.new(36),
      Book.new(45),
      Brain.new(5),
      Book.new(45),
      Brain.new(12),
      Brain.new(7.6),
      Book.new(45),
      Brain.new(3.2)
    ]
    
  end
  
end