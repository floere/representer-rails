class CartController < ApplicationController
  
  include PresenterHelper
  
  def index
    load_books
    load_brains
    shuffle_items
    
    @controller_presenter = presenter_for Book.new
  end
  
  def books_each_partial
    load_books
  end
  
  def description_line_in_model
    load_books
  end
  
  def current_user
    # get the current user from the session
  end
  
  private
  
  def shuffle_items
    @items = @items.sort_by{rand}
  end
  
  def load_books(count=10)
    @items ||= []
    count.times do
      @items << Book.new
    end
  end
  
  def load_zombie_books(count=10)
    @items ||= []
    count.times do
      @items << Book.new(true)
    end
  end
  
  def load_brains(count=10)
    @items ||= []
    count.times do
      @items << Brain.new
    end
  end
  
end