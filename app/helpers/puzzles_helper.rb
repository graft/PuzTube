module PuzzlesHelper
  def broadcast_puzzle_edit(puzzle,params)
    if ((params[:answer] =~ /[A-Za-z]/ || params[:status] == "Solved") && puzzle.status != "Solved")
      params[:status] = "Solved"
      params[:priority] = "Low"
      broad = true
    else
      broad = false
    end
    if puzzle.update_attributes(params)
      Push.send :command => "update puzzle", :channel => puzzle.round.hunt.chat_id, :puzzle => puzzle.id, :table => puzzle.t_id
      Push.send :command => "update puzzle info", :channel => puzzle.chat_id, :puzzle => puzzle.id
      Push.send :command => "chat", :text => "<li>#{h Time.now.strftime("%H:%M")} <b>MAYHEM BROADCAST</b> <font style=#{ javascript_escape("'color: red;'")}>Puzzle #{h puzzle.name} in Round #{h javascript_escape puzzle.round.name} was solved with answer #{h javascript_escape puzzle.answer}</font></li>"
    end
  end
end
