ActionController::Routing::Routes.draw do |map|
  map.resources :user_comments

  map.connect 'search', :action => 'search', :controller => 'application'

  map.connect ':kind/browse', :action => 'index', :controller => 'tags'
  map.connect ':obj_type/browse/:name', :action => 'show', :controller => 'tags', :requirements => { :name => /.*\/*/ }
  map.connect 'tags/:link', :action => 'redirect', :controller => 'tags'

  map.connect 'index.atom', :action => 'index', :controller => 'application', :format => 'atom'
  map.connect 'posts.atom', :action => 'index', :controller => 'posts', :format => 'atom'
  map.connect 'users/search', :action => 'search', :controller => 'users'

  map.connect 'users/invite', :action => 'invite', :controller => 'users'
  map.connect 'users/invite/:m', :action => 'invite', :controller => 'users'

  map.connect 'users/forgot_password', :action => 'forgot_password', :controller => 'users'
  map.connect 'users/reset_password/:password_reset_code', :action => 'reset_password', :controller => 'users'
  map.connect 'users/change_password', :action => 'change_password', :controller => 'users'

  map.connect 'users/request_friendship/:id', :action => 'request_friendship', :controller => 'users', :requirements => { :id => /.*/ }
  map.connect 'users/accept_friendship/:id', :action => 'accept_friendship', :controller => 'users', :requirements => { :id => /.*/ }
  map.connect 'users/decline_friendship/:id', :action => 'decline_friendship', :controller => 'users', :requirements => { :id => /.*/ }
  map.connect 'users/cancel_friendship/:id', :action => 'cancel_friendship', :controller => 'users', :requirements => { :id => /.*/ }

  map.connect 'posts/search', :action => 'search', :controller => 'posts'
  map.connect 'requests/hide_selcted', :action => 'hide_selected', :controller => 'requests'


  map.resources :users, :collection => { :tag_suggestions => :get }, :requirements => { :id => /.*/ } do |users|
    users.resources :messages, :collection => {  :delete_selected => :post }
  end

  map.resources :requests

  map.resources :posts, :collection => { :tag_suggestions => :get } do |post|
      post.resources :comments
  end

  map.resources :comments

  map.resources :interests

  map.resources :tags


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
  map.root :controller => "application"
  map.page ":page", :controller => "pages", :action => 'show', :page => /about|contact|terms|links/

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'

end
