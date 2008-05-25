class CartController < ApplicationController
  
  include PresenterHelper
  
  def index
    
    @items = []
    10.times do
      @items << Book.new
      @items << Brain.new
    end
    
    # Presenters can be assigned in controllers, too:
    @controller_presenter = presenter_for Book.new
    
  end
  
  def current_user
    # get the current user from the session
  end
  
end