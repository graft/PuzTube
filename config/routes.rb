ActionController::Routing::Routes.draw do |map|
  map.resources :hunts

  map.edit_puzzlerow '/puzzles/edit_row', :controller => 'puzzles', :action => 'edit_row'
  map.delete_puzzle '/puzzles/delete/:id', :controller => 'puzzles', :action => 'destroy', :method => :delete
  map.edit_puzzle '/puzzles/edit/:id', :controller => 'puzzles', :action => 'edit'
  map.update_puzzle '/puzzles/update/:id', :controller => 'puzzles', :action => 'update'
  map.new_puzzle '/puzzles/new/:id', :controller => 'puzzles', :action => 'new'
  map.worker_puzzle '/puzzles/worker/:id', :controller => 'puzzles', :action => 'worker'
  map.puzzle '/puzzles/:id', :controller => 'puzzles', :action => 'show'

  map.create_rpuzzle '/rounds/create_puzzle', :controller => 'rounds', :action => 'create_puzzle'
  map.new_round '/hunts/new_round/:id', :controller => 'hunts', :action => 'new_round'
  map.delete_round '/rounds/delete/:id', :controller => 'rounds', :action => 'destroy', :method => :delete
  map.edit_round '/rounds/edit/:id', :controller => 'rounds', :action => 'edit'
  map.rounds '/rounds', :controller => 'rounds', :action => 'index'

  map.info_round '/round/info', :controller => 'rounds', :action => 'info'
  map.round '/round/:id', :controller => 'rounds', :action => 'show'

  map.options_user '/users/options', :controller => 'users', :action => 'options'
  map.login '/login', :controller => 'users', :action => 'login'
  
  map.resources :users
  map.resources :chats
  map.resources :rounds

  map.subscribe '/connections/subscribe', :controller => 'connections', :action => 'subscribe'
  map.unsubscribe '/connections/unsubscribe', :controller => 'connections', :action => 'unsubscribe'

  map.edit_topic 'topic/:name/edit', :controller => 'topics', :action => 'edit'
  map.update_topic 'topic/:name', :controller => 'topics', :action => 'update', :conditions => { :method => :put }
  map.new_topic 'topic/new', :controller => 'topics', :action => 'new'
  map.create_topic 'topic', :controller => 'topics', :action => 'create', :conditions => { :method => :post }
  map.destroy_topic 'topic/:name', :controller => 'topics', :action => 'destroy', :conditions => { :method => :delete }
  map.topics 'topics', :controller => 'topics', :action => 'index'
  map.topic 'topic/:name', :controller => 'topics', :action => 'show'

  map.chat_log 'chats/log/:channel', :controller => 'chats', :action => 'log'

  map.new_attachment 'workspace/new_attachment', :controller => 'workspace', :action => 'new_attachment', :conditions => { :method => :post }
  map.delete_attachment 'workspace/delete_attachment', :controller => 'workspace', :action => 'delete_attachment'

  map.new_workspace 'workspace/new', :controller => 'workspace', :action => 'new', :conditions => { :method => :post }
  map.delete_workspace 'workspace/delete', :controller => 'workspace', :action => 'delete'
  map.prioritize_workspace 'workspace/prioritize', :controller => 'workspace', :action => 'prioritize'
  map.edit_workspace 'workspace/edit', :controller => 'workspace', :action => 'edit'
  map.show_workspace 'workspace/show', :controller => 'workspace', :action => 'show'
  map.update_workspace 'workspace/update', :controller => 'workspace', :action => 'update'

  map.new_table 'table/new', :controller => 'table', :action => 'new', :conditions => { :method => :post }
  map.delete_table 'table/delete', :controller => 'table', :action => 'delete'
  map.prioritize_table 'table/prioritize', :controller => 'table', :action => 'prioritize'
  map.edit_table 'table/edit', :controller => 'table', :action => 'edit'
  map.show_table 'table/show', :controller => 'table', :action => 'show'
  map.update_table 'table/update', :controller => 'table', :action => 'update'
  map.update_cell 'table/update_cell', :controller => 'table', :action => 'update_cell'
  map.rc_table 'table/rc', :controller => 'table', :action => 'get_rc'
  map.root :controller => 'topics', :action => 'show', :name => 'Project Electric Mayhem'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
end
