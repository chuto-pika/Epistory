Rails.application.routes.draw do
  get "/health", to: proc { [200, {}, ["ok"]] }

  root "pages#home"

  get "/login", to: "sessions#new", as: :login
  delete "/logout", to: "sessions#destroy", as: :logout
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  get "/terms", to: "pages#terms"
  get "/privacy", to: "pages#privacy"

  get "/contact", to: "contacts#new", as: :contact
  post "/contact", to: "contacts#create"
  get "/contact/complete", to: "contacts#complete", as: :contact_complete

  resource :message, only: [:new] do
    collection do
      controller "messages/steps" do
        get  :step1
        post :step1, action: :save_step1
        get  :step2
        post :step2, action: :save_step2
        get  :step3
        post :step3, action: :save_step3
        get  :step4
        post :step4, action: :save_step4
        get  :step5
        post :step5, action: :save_step5
        get  :step6
        post :step6, action: :save_step6
      end
    end
  end

  resources :messages, only: %i[show edit update destroy] do
    member do
      patch :restore
      patch :survey
    end
  end
end
