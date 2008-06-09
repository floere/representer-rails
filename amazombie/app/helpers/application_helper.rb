# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # This seems to be the classic Rails/MVC way.
  # Is not OO.
  # Feels awkward, when needed for more models.
  #
  def description_line_helper(item)
    case item
    when Book
      %Q{"#{item.title}", #{item.pages} S. &mdash; #{item.price}}
    when Brain
      %Q{"#{item.former_host}", IQ #{item.iq} &mdash; #{item.price} EUR}
    end
  end
  
  def cart_controller_method_links
    mets = CartController.example_methods
    links = mets.map{ |met| content_tag( 'li', link_to(met, :controller => 'cart', :action => met) ) }
    content_tag 'ul', links
  end
  
end
