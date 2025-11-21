Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/emails" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check

  # API namespace for React SPA
  namespace :api do
    namespace :v1 do
      # Auth endpoints (using Devise sessions)
      get "auth/me", to: "sessions#me"
      post "auth/sign_in", to: "sessions#create"
      post "auth/verify_mfa", to: "sessions#verify_mfa"
      delete "auth/sign_out", to: "sessions#destroy"
      post "auth/sign_up", to: "registrations#create"

      # MFA endpoints
      get "users/two_factor_setup/new", to: "two_factor_setup#new"
      post "users/two_factor_setup", to: "two_factor_setup#create"
      delete "users/two_factor_setup", to: "two_factor_setup#destroy"
      get "users/two_factor_setup/backup_codes", to: "two_factor_setup#backup_codes"

      # Audit logs
      get "audits/phi_access", to: "audits#phi_access"
      resources :audits, only: [:index, :show]
    end
  end

  # Keep Devise for session management (cookies), but skip HTML routes
  # React SPA handles all UI - we only need Devise's session methods in controllers
  devise_for :users, skip: [:registrations, :sessions, :passwords], controllers: {}

  root "homepage#index"

  # React SPA catch-all route - must be last
  # This handles all HTML requests that aren't API calls
  get "*path", to: "homepage#index", constraints: ->(req) { !req.xhr? && req.format.html? && !req.path.start_with?("/api") }
end

