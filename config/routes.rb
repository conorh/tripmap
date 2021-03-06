ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resource :user_session
  map.resource :account, :controller => "users"
  
  map.root :controller => "main"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
