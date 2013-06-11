Cms::Engine.routes.draw do

  # Aloha Resources Redirect:

  match "/img/:img.png" => redirect("/assets/%{img}.png")
  match "/img/:img.gif" => redirect("/assets/%{img}.gif")

  match "/lib/vendor/ext-3.2.1/resources/images/gray/qtip/:img.gif" => redirect("/assets/aloha/lib/vendor/ext-3.2.1/resources/images/gray/qtip/%{img}.gif")
  match "/lib/vendor/ext-3.2.1/resources/images/gray/tabs/:img.gif" => redirect("/assets/aloha/lib/vendor/ext-3.2.1/resources/images/gray/tabs/%{img}.gif")
  match "/lib/vendor/ext-3.2.1/resources/images/gray/button/:img.gif" => redirect("/assets/aloha/lib/vendor/ext-3.2.1/resources/images/gray/button/%{img}.gif")
  match "/lib/vendor/ext-3.2.1/resources/images/gray/toolbar/:img.gif" => redirect("/assets/aloha/lib/vendor/ext-3.2.1/resources/images/gray/toolbar/%{img}.gif")

  root :to => "pages#default_layout"

  resources :tests do
    get '/' => 'tests#basic'
    post '/' => 'tests#create'
  end

  resources :pages do
    collection do
      get 'show'
      get 'default_layout'
    end
  end

  resources :page_contents do
    collection do
      post 'aloha'
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

  resources :gallery do
    collection do
      post "upload"
      post "delete_image"
      post "panel_gallery"
      put "rename_image"
      get "upload_success"
    end
  end

  resources :source_manager do
    collection do
      post "panel_main"
      post "panel_structure"
      post "panel_content"
      post "panel_components"
      post "panel_settings"
      post "update_page_properties"
      post "create_folder"
      post "create_component"
      post "save_component"
      post "reorder_sources"
      post "update_cms_settings"

      get 'tool_bar'
      get 'get_panel_data'
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
