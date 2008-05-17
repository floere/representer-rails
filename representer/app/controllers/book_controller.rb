class BookController < ApplicationController
  
  def index
    
    @books = [
      Book.new(36),
      Book.new(45),
      Book.new(121),
      Book.new(100)
    ]
    
  end
  
end
