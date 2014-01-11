Puztube2::Application.routes.draw do
  resources :hunts
  match '/hunts/stats/:id' => 'hunts#stats', :as => :stats

  match '/threads/:channel/chat' => 'threads#chat', :as => :thread_chat

  match '/puzzle/destroy/:id' => 'puzzles#destroy', :method => :delete, :as => :destroy_puzzle
  match '/puzzle/edit/:id' => 'puzzles#edit', :as => :edit_puzzle
  match '/puzzle/worker/:id' => 'puzzles#worker', :as => :worker_puzzle 
  match '/puzzle/create' => 'puzzles#create', :as => :create_puzzle 
  match '/puzzle/:id' => 'puzzles#show', :as => :show_puzzle
  match '/puzzle/:channel/get' => 'puzzles#get', :as => :get_puzzle
  match '/puzzle/:id/activities' => 'puzzles#activities', :as => :puzzle_activities


  match '/rounds/destroy/:id' => 'rounds#destroy', :method => :delete, :as => :destroy_round 
  match '/rounds/:id/edit' => 'rounds#edit', :as => :edit_round 
  match '/rounds/create' => 'rounds#create', :as => :create_round
  match '/rounds' => 'rounds#index', :as => :rounds 
  match '/round/info' => 'rounds#info', :as => :info_round 
  match '/round/:id' => 'rounds#show', :as => :show_round 

  match '/hunt/:channel/get' => 'hunts#get', :as => :get_hunt
  match '/hunts/new' => 'hunts#new', :as => :new_hunt

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
  match '/topic/:channel/get' => 'topics#get', :as => :get_topic
  match '/topic/show/:name' => 'topics#show', :as => :topic 

  match '/workspace/new_attachment' => 'workspace#new_attachment', :conditions => { :method => :post }, :as => :new_attachment 
  match '/workspace/delete_attachment' => 'workspace#delete_attachment', :as => :delete_attachment 

  match '/workspace/create' => 'workspace#create', :as => :create_workspace
  match '/workspace/destroy/:id' => 'workspace#delete', :as => :delete_workspace 
  match '/workspace/edit' => 'workspace#edit', :as => :edit_workspace 
  match '/workspace/show' => 'workspace#show', :as => :show_workspace 
  match '/workspace/edit/:id' => 'workspace#update', :as => :update_workspace 
  match '/workspace/table/:id' => 'workspace#table', :as => :workspace_table 

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
