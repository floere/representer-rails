ActionController::Routing::Routes.draw do |map|
  
  map.connect '/:action', :controller => 'cart'
  map.connect '/', :controller => 'cart', :action => 'index'
  
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
