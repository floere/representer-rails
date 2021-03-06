class CartController < ApplicationController
  
  include PresenterHelper
  
  def self.example_methods
    # books_each_partial description_line_in_model description_line_helper
    %w{simple_presenter presenter_with_filter presenter_with_render_as collection_presenter collection_presenter.text}
  end
  
  def index
    redirect_to :action => 'simple_presenter'
  end
  
  def books_each_partial
    load_books
  end
  
  def description_line_in_model
    load_books_and_brains
  end
  
  def description_line_helper
    load_books_and_brains
  end
  
  def simple_presenter
    load_books_and_brains
  end
  
  def presenter_with_filter
    load_books_and_brains
  end
  
  def presenter_with_render_as
    load_books_and_brains
  end
  
  def collection_presenter
    load_books_and_brains
  end
  
  
  def current_user
    # get the current user from the session
  end
  
  private
  
  def load_books_and_brains
    load_books(5)
    load_zombie_books(5)
    load_brains(5)
    shuffle_items
  end
  
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