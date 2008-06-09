# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def cart_controller_method_links
    mets = CartController.example_methods
    mets.map{|met| link_to met, :controller => 'cart', :action => met}.join( tag('br') )
  end
  
end
