InsalesApp::Application.routes.draw do
  root to: 'main#index'
  get '/seo_filters_update', to: 'main#seo_filters_update'
  get '/put_one_product', to: 'main#put_one_product'
  get '/put_all_products', to: 'main#put_all_products'

  resource  :session do
    collection do
      get :autologin
    end
  end

  get '/install',   to: 'insales_app#install',   as: :install
  get '/uninstall', to: 'insales_app#uninstall', as: :uninstall
  get '/login',     to: 'sessions#new',          as: :login
  get '/main',      to: 'main#index',            as: :main

  get ':controller/:action/:id'
  get ':controller/:action/:id.:format'
end
