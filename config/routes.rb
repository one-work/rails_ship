Rails.application.routes.draw do
  concern :my_ship do
    resources :addresses do
        collection do
          get :list
          post :select
          post :fork
          post :wechat
          post :program
          post :order
          post :order_from
          post :order_new
          post :order_create
          post :from_new
          post :from_create
        end
        member do
          get :join
        end
      end
    resources :carts, only: [] do
      resources :addresses, controller: 'cart/addresses' do
        collection do
          post :select
          get :cart
          get :station
          post :order
          post :order_new
          post :order_create
          post :fork
          post :wechat
          post :program
        end
        member do
          get :plans
        end
      end
    end
  end

  namespace :ship, defaults: { business: 'ship' } do
    resources :areas, only: [:index] do
      collection do
        get :search
        get :list
      end
      member do
        match :follow, via: [:get, :post]
        post :child
        post :input
      end
    end
    resources :box_hosts, only: [:index, :show] do
      collection do
        get :overview
        get :rent
        get :invest
      end
      member do
        get :all
        get :rentable
        get :rented
      end
      resources :boxes, only: [:index]
      resources :box_proxy_buys
      resources :box_proxy_sells
    end
    resources :boxes, only: [] do
      collection do
        post :in_create
      end
      member do
        get :qrcode
        get 'in' => :in_edit
        post 'in' => :in_update
      end
    end
    resources :shipments, only: [] do
      member do
        get :qrcode
      end
    end
    resources :packages, only: [] do
      member do
        get :qrcode
      end
    end
    namespace :panel, defaults: { namespace: 'panel' } do
      root 'home#index'
      resources :areas
      resources :lines do
        resources :similars
        resources :line_stations do
          member do
            patch :reorder
          end
        end
      end
      resources :stations
      resources :box_specifications do
        resources :boxes do
          collection do
            post :batch
            match :batch_pdf, via: [:get, :post]
          end
          member do
            get :pdf
          end
          resources :box_logs
          resources :rents do
            member do
              get :promote
              get :job
              put :compute
            end
          end
        end
        resources :box_hosts
      end
    end
    namespace :admin, defaults: { namespace: 'admin' } do
      resources :stations do
        member do
          get :lines
          get :shipments
        end
        collection do
          post :select
        end
      end
      resources :users, only: [:index]
      resources :addresses do
        collection do
          get :from
          get :packaged
          post :search
        end
      end
      resources :items, except: [:destroy] do
        collection do
          get 'address/:address_id' => :packable
          get 'packaged/:address_id' => :packaged
          get 'user/:user_id' => :user
        end
      end
      resources :packages do
        resources :packageds
        collection do
          get :address
        end
        member do
          get :pdf
          get :print_data
          get :shipment_items
        end
      end
      resources :cars
      resources :drivers
      resources :lines do
        resources :line_stations
        resources :shipments do
          member do
            get :stations
            get 'loaded/:from_station_id' => :loaded
            post 'loaded' => :loaded_create
            get 'unloaded/:station_id' => :unloaded
            post 'unloaded' => :unloaded_create
            get 'transfer/:station_id' => :transfer
            post :leave
            post :arrive
          end
          resources :shipment_items
          resources :shipment_logs
          resources :payment_orders do
            collection do
              get 'station/:station_id' => :station
            end
            member do
              get 'payment' => :payment_new
              post 'payment' => :payment_create
            end
          end
        end
      end
      resources :ways do
        resources :locations
      end
      resources :box_hosts do
        member do
          get :wallet
          patch 'wallet' => :update_wallet
        end
        resources :box_proxy_sells do
          resources :box_sells
        end
        resources :box_proxy_buys
        resources :box_holds
        resources :boxes do
          collection do
            post :batch
            match :batch_pdf, via: [:get, :post]
          end
          member do
            get :pdf
          end
          resources :box_logs
          resources :rents
        end
      end
      root 'home#index'
    end
    namespace :in, defaults: { namespace: 'in' } do
      resources :box_specifications, only: [:index, :show] do
        collection do
          get :buy
          get :rent
        end
      end
      resources :boxes do
        collection do
          get :invest
          get :rent
        end
        resources :box_logs
        resources :rents do
          member do
            get :promote
            get :job
            put :compute
            patch :finish
          end
        end
      end
      resources :orders do
        member do
          get :payment_types
          get 'payment_type' => :edit_payment_type
        end
        resources :items
      end
      resources :items
    end
    namespace :out, defaults: { namespace: 'out' } do
      resources :boxes do
        resources :rents
      end
    end
    namespace :our, defaults: { namespace: 'our' } do
      concerns :my_ship
      resources :orders do
        member do
          get :payment_types
          get 'payment_type' => :edit_payment_type
        end
        resources :items
      end
      resources :rents do
        member do
          get :promote
          get :job
          put :compute
        end
      end
      resources :boxes
    end
    namespace :dri, defaults: { namespace: 'dri' } do
      resources :favorites
    end
    namespace :me, defaults: { namespace: 'me' } do
      resources :packages do
        member do
          post :in
          post :out
          post :loaded
          post :unloaded
          post :package
          get :qrcode
        end
      end
      resources :boxes do
        member do
          post :in
          post :out
          get :qrcode
        end
        resources :rents do
          member do
            patch :finish
          end
        end
      end
      resources :cars do
        collection do
          post :package_in
          post :package_out
        end
        member do
          get :qrcode
        end
      end
      resources :shipments do
        member do
          post :loaded
          post :unloaded
          get :qrcode
        end
      end
    end
    namespace :agent, defaults: { namespace: 'agent' } do
      concerns :my_ship
    end
    namespace :my, defaults: { namespace: 'my' } do
      concerns :my_ship
      resource :driver
      resources :favorites
      resources :cars
      resources :ways do
        collection do
          get :requirement
          post :add
          post :select
        end
        resources :locations
      end
      resources :stations
      resources :box_holds do
        collection do
          get :sell
        end
        member do
          get :buy
        end
        resources :orders, only: [:create]
        resources :items, only: [:index, :show] do
          collection do
            get :rent
          end
        end
        resources :boxes
        resources :box_sells, only: [:index, :show, :create, :destroy]
      end
      resources :box_hosts, only: [] do
        resources :box_entrusts do
          collection do
            get :sell
          end
        end
      end
      resources :boxes, only: [] do
        collection do
          get :owned
          get :invest
        end
        member do
          get :qrcode
          get :owned_show
          post :start
        end
        resources :rents
      end
      resources :packages do
        member do
          get :qrcode
          put :wait
          post :receive
        end
      end
    end
  end

  resolve 'Ship::BoxHost' do |box_host, options|
    [:ship, box_host, options]
  end
end
