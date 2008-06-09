# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def cart_controller_method_links
    mets = CartController.example_methods
    links = mets.map{ |met| content_tag( 'li', link_to(met, :controller => 'cart', :action => met) ) }
    content_tag 'ul', links
  end
  
end
