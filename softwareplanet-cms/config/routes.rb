Cms::Engine.routes.draw do

  # Aloha Resources Redirect:

  match "/img/:img.png" => redirect("/assets/%{img}.png")
  match "/img/:img.gif" => redirect("/assets/%{img}.gif")




  root :to => "pages#show", :layout => "welcome"

  resources :tests do
    get '/' => 'tests#basic'
    post '/' => 'tests#create'
  end

  resources :pages do
    collection do
      get 'show'
    end
  end

  resources :adm do
    collection do
      get 'login'
      get 'reset'
      post 'login_submit'
      get 'logout'
    end
  end

  resources :source_manager do
    collection do
      post "upload"
      get "upload_success"
      post "delete_image"
      put "rename_image"
      post "panel_main"
      post "panel_structure"
      post "panel_content"
      post "panel_components"
      post "panel_gallery"
      post "panel_settings"
      post "save_properties"
      post "create_folder"
      post "create_component"
      post "save_component"

      get 'tool_bar'
      get 'menu_bar'
      get 'editor'
      get 'properties'
    end
  end

  resources :page_layouts do
    collection do
      get "backup"
      post "upload"
    end
  end

  resources :page_contents do
    collection do
      post 'aloha'
    end
  end

  resources :user_interfaces do
    collection do
      get 'set_locale'
      post 'set_mode'
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'



  match '/in' => 'adm#login'
  match ':locale/:layout' => 'pages#show', :constraints => {:format => ''}
  match ':layout' => 'pages#show'


end
