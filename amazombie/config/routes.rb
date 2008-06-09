ActionController::Routing::Routes.draw do |map|
  map.connect '/:action', :controller => 'cart'
  map.connect '/:action.:format', :controller => 'cart'
end
