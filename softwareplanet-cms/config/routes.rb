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
      post "delete_image"
      post "panel_main"
      post "panel_structure"
      post "panel_content"
      post "panel_components"
      post "panel_gallery"
      post "panel_settings"
      post "update_page_properties"
      post "create_folder"
      post "create_component"
      post "save_component"
      post "reorder_layouts"

      put "rename_image"

      get "upload_success"
      get 'tool_bar'
      get 'menu_bar'
      get 'editor'
    end
  end

  resources :source_code do
    collection do
      post 'edit_source_code'
      post 'update_source_code'
    end
  end

  resources :page_layouts do
    collection do
      get "backup"
      post "upload"
    end
  end

  resources :user_interfaces do
    collection do
      get 'set_locale'
      post 'set_mode'
    end
  end

  match '/in' => 'adm#login'
  match ':locale/:layout' => 'pages#show', :constraints => {:format => ''}
  match ':layout' => 'pages#show'
end
