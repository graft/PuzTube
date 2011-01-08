ActionController::Routing::Routes.draw do |map|
  map.connect '/puzzles/edit_row', :controller => 'puzzles', :action => 'edit_row'
  map.delete_puzzle '/puzzles/delete/:id', :controller => 'puzzles', :action => 'destroy', :method => :delete
  map.edit_puzzle '/puzzles/edit/:id', :controller => 'puzzles', :action => 'edit'
  map.update_puzzle '/puzzles/update/:id', :controller => 'puzzles', :action => 'update'
  map.new_puzzle '/puzzles/new/:id', :controller => 'puzzles', :action => 'new'
  map.puzzle '/puzzles/:id', :controller => 'puzzles', :action => 'show'

  map.create_rpuzzle '/rounds/create_puzzle', :controller => 'rounds', :action => 'create_puzzle'
  map.new_round '/rounds/new', :controller => 'rounds', :action => 'new'
  map.delete_round '/rounds/delete/:id', :controller => 'rounds', :action => 'destroy', :method => :delete
  map.edit_round '/rounds/edit/:id', :controller => 'rounds', :action => 'edit'
  map.rounds '/rounds', :controller => 'rounds', :action => 'index'
  map.round '/round/:id', :controller => 'rounds', :action => 'show'

  map.resources :users

  #map.resources :topics

  map.resources :chats

  #map.resources :puzzles

  map.resources :rounds

  map.connect '/connections/subscribe', :controller => 'connections', :action => 'subscribe'
  map.connect '/connections/unsubscribe', :controller => 'connections', :action => 'unsubscribe'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => 'topics', :action => 'show', :name => 'Project Electric Mayhem'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

  map.edit_topic 'topic/:name/edit', :controller => 'topics', :action => 'edit'
  map.update_topic 'topic/:name', :controller => 'topics', :action => 'update', :conditions => { :method => :put }
  map.new_topic 'topic/new', :controller => 'topics', :action => 'new'
  map.create_topic 'topic', :controller => 'topics', :action => 'create', :conditions => { :method => :post }
  map.destroy_topic 'topic/:name', :controller => 'topics', :action => 'destroy', :conditions => { :method => :delete }
  map.topics 'topics', :controller => 'topics', :action => 'index'
  map.topic 'topic/:name', :controller => 'topics', :action => 'show'

  map.new_workspace 'workspace/new', :controller => 'workspace', :action => 'new', :conditions => { :method => :post }
  map.delete_workspace 'workspace/delete', :controller => 'workspace', :action => 'delete'
  map.edit_workspace 'workspace/edit', :controller => 'workspace', :action => 'edit'
  map.update_workspace 'workspace/update', :controller => 'workspace', :action => 'update'

  #map.connect ':controller/:id/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id.:format'
end
