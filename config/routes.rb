ItRoom::Application.routes.draw do
  match "users/forgotten_password"
  post "users/update_password"

  resources :term_dates

  get "timetable", :to => 'timetable#index'

  post "timetable/show"
  get "timetable/show"

  root :to => "welcome#index"

  get "bookings", :to => "bookings#index"
  post "bookings", :to => "bookings#search"
  post "bookings/book"

  get "admin/login"
  post "admin/login"
  get "admin/logout"
  get "admin/preferences"

  resources :users
  post "users/log_in_as/:user_id", :to => "users#log_in_as"
  post "users/search"

  resources :rooms

  get "bookings/my_bookings"
  delete "bookings/delete/:id", :to => "bookings#delete"

  get "admin/change_week"
  get "admin/change_end_term"
  post "admin/change_end_term"

  get "admin/auto_book"
  post "admin/auto_book"

  post "users/update_language"
  post "bookings/get_reasons"
  post "/bookings/call_ids_by_type"

  get "timetable/show_reason/:id", :to => "timetable#show_reason", :as => "timetable_show_reason"
end

