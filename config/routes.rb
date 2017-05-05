Rails.application.routes.draw do
  post   '/sign_in',        to: 'sessions#sign_in'
  delete '/sign_out',       to: 'sessions#sign_out'
  patch  '/confirm',        to: 'sessions#confirm'
  post   '/reset_password', to: 'sessions#request_reset_password'
  patch  '/reset_password', to: 'sessions#reset_password'
end
