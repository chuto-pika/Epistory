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
    end
  end
end
