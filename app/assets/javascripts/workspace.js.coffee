@puztubeApp.factory 'Workspaces', [ '$http', '$sce', ($http, $sce) ->
  @add = (type) => 
    $http.post(Routes.create_workspace_path({ thread_id: @thread.id, thread_type: @thread_type, workspace_type: type })).success ->
      @thread.adding_workspace = false
  @is_editable = (workspace) => @workspace_type(workspace.workspace_type).editable

  @workspace_type = (type) => (w for w in @workspace_types when w.type is type or w.template is type)[0]

  @workspace_types = [
      type: 'text'
      template: 'workspace_text'
      title: "A text editor that renders Markdown"
      editable: true
    ,
      type: 'etherpad'
      template: 'workspace_etherpad'
      title: "Just an etherpad"
    ,
      type: 'table'
      template: 'workspace_table'
      title: "Real-time table editor"
    ,
      type: 'attachments'
      template: 'workspace_files'
      title: "Attachments"
      editable: true
  ]

  @edit = (workspace) =>
    workspace.editing =
      title: workspace.title
      content: workspace.content
      thread_id: workspace.thread_id
      thread_type: workspace.thread_type
    workspace.locktime = new Date()

  @delete = (workspace) =>
    return unless confirm "Are you sure?"
    $http.post(Routes.delete_workspace_path(workspace.id))

  @post = (workspace) =>
    $http.post(Routes.update_workspace_path(workspace.id,{ workspace: workspace.editing, locktime: workspace.locktime }))
      .success => workspace.editing = null

  @cancel = (workspace) => workspace.editing = null

  @process = (workspace) =>
    return if workspace.priority == "Hidden"
    if workspace.workspace_type == 'workspace_text'
      if workspace.content
        workspace.markdown_content = $sce.trustAsHtml(markdown.toHTML(workspace.content))


  @add_row = (workspace) =>
    $http.post(Routes.workspace_table_path(workspace.id, { add: "row" }))
  @add_col = (workspace) =>
    $http.post(Routes.workspace_table_path(workspace.id, { add: "col" }))

  @update_cell = (workspace,cell) =>
    $http.post(Routes.workspace_table_path(workspace.id, { update: cell.contents, row: cell.row, col: cell.col }))

  @
]
