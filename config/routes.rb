NearSpeak::Application.routes.draw do
  # api v1
  namespace :api, :defaults => { :format => :json }  do
    namespace :v1 do
      post 'login/get_auth_token'
      post 'login/getAuthToken', to: 'login#get_auth_token'
      post 'login/sign_out'
      post 'login/signOut', to: 'login#sign_out'
      post 'login/sign_in_with_facebook'
      post 'login/signInWithFacebook', to: 'login#sign_in_with_facebook'

      get 'tags/show'
      get 'tags/show_by_hardware_id'
      get 'tags/showByHardwareId', to: 'tags#show_by_hardware_id'
      get 'tags/showMyTags', to: 'tags#show_my_tags'
      get 'tags/supported_language_codes'
      get 'tags/supportedLanguageCodes', to: 'tags#supported_language_codes'
      get 'tags/supportedBeaconUUIDs', to: 'tags#get_all_uuids'
      post 'tags/create'
      post 'tags/add_hardware_id_to_tag'
      post 'tags/addHardwareIdToTag', to: 'tags#add_hardware_id_to_tag'
    end
  end

  root :to => 'overview#index'

  devise_for :customers, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  resources :customers, :except => [:index]

  resources :places

  resources :tags

  resources :text_records, :except => [:index]

  resources :translations, :except => [:index]

  resources :name_translations, :except => [:index]

  resources :hardwares, :except => [:index]
end
