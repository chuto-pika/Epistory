Rails.application.routes.draw do
  root "pages#home"

  resource :message, only: [:new] do
    collection do
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

  resources :messages, only: [:show]
end
