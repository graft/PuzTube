Puztube2::Application.routes.draw do
  resources :hunts
  match '/hunts/stats/:id' => 'hunts#stats', :as => :stats

  match '/threads/:channel/chat' => 'threads#chat', :as => :thread_chat

  match '/puzzles/edit_row' => 'puzzles#edit_row', :method => :post, :as => :edit_puzzlerow
  match '/puzzles/delete/:id' => 'puzzles#destroy', :method => :delete, :as => :delete_puzzle
  match '/puzzles/edit/:id' => 'puzzles#edit', :as => :edit_puzzle
  match '/puzzles/update/:id' => 'puzzles#update', :as => :update_puzzle
  match '/puzzles/info' => 'puzzles#info', :as => :info_puzzle 
  match '/puzzles/worker/:id' => 'puzzles#worker', :as => :worker_puzzle 
  match '/puzzles/:id' => 'puzzles#show', :as => :puzzle 
  match '/puzzles/:id/activities' => 'puzzles#activities', :as => :puzzle_activities


  match '/rounds/create_puzzle' => 'rounds#create_puzzle', :as => :create_rpuzzle 
  match '/hunts/new_round/:id' => 'hunts#new_round', :as => :new_round 
  match '/rounds/delete/:id' => 'rounds#destroy', :method => :delete, :as => :delete_round 
  match '/rounds/edit/:id' => 'rounds#edit', :as => :edit_round 
  match '/rounds' => 'rounds#index', :as => :rounds 

  match '/hunt/:hunt/rounds' => 'rounds#list', :as => :rounds_list
  match '/hunt/:channel/get' => 'hunts#get', :as => :get_hunt

  match '/round/info' => 'rounds#info', :as => :info_round 
  match '/round/:id' => 'rounds#show', :as => :round 

  match '/users/options' => 'users#options', :as => :options_user 
  match '/login' => 'users#login', :as => :login 
  match '/logout' => 'welcome#logout', :as => :logout 
  match '/welcome' => 'welcome#login', :as => :welcome 
  
  resources :users
  match '/users/:name' => 'users#show', :as => :connect 

  resources :chats
  match '/chats/log/:channel' => 'chats#log', :as => :chat_log 
  match '/chats/window/:channel' => 'chats#window', :as => :chat_window 
  match '/chats/recent/:channel' => 'chats#recent', :as => :recent_chats 
  match '/broadcasts' => 'chats#broadcasts', :as => :broadcasts 

  resources :rounds

  match '/connections/subscribe' => 'connections#subscribe', :as => :subscribe 
  match '/connections/unsubscribe' => 'connections#unsubscribe', :as => :unsubscribe 

  match '/topic/:name/edit' => 'topics#edit', :as => :edit_topic 
  match '/topic/:name' => 'topics#update', :method => :put, :as => :update_topic
  match '/topic/new' => 'topics#new', :as => :new_topic 
  match '/topic' => 'topics#create', :method => :post, :as => :create_topic 
  match '/topic/:name' => 'topics#destroy', :method => :delete, :as => :destroy_topic 
  match '/topics' => 'topics#index', :as => :topics 
  match '/topic/show/:name' => 'topics#show', :as => :topic 

  match '/workspace/new_attachment' => 'workspace#new_attachment', :conditions => { :method => :post }, :as => :new_attachment 
  match '/workspace/delete_attachment' => 'workspace#delete_attachment', :as => :delete_attachment 

  match '/workspace/new' => 'workspace#new', :conditions => { :method => :post }, :as => :new_workspace 
  match '/workspace/delete' => 'workspace#delete', :as => :delete_workspace 
  match '/workspace/prioritize' => 'workspace#prioritize', :as => :prioritize_workspace 
  match '/workspace/edit' => 'workspace#edit', :as => :edit_workspace 
  match '/workspace/show' => 'workspace#show', :as => :show_workspace 
  match '/workspace/update' => 'workspace#update', :as => :update_workspace 

  match '/table/new' => 'table#new', :conditions => { :method => :post }, :as => :new_table
  match '/table/delete' => 'table#delete', :as => :delete_table 
  match '/table/prioritize' => 'table#prioritize', :as => :prioritize_table 
  match '/table/edit' => 'table#edit', :as => :edit_table 
  match '/table/show' => 'table#show', :as => :show_table 
  match '/table/update' => 'table#update', :as => :update_table 
  match '/workspace/update_cell' => 'workspace#update_cell', :as => :update_cell 
  match '/workspace/rc' => 'workspace#add_rc', :as => :add_rc 

  root :to => 'topics#show', :name => 'Project Electric Mayhem'
end
