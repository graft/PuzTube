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
      txt = render_to_string :partial => 'miniinfo', :locals => { :puzzle => puzzle }
      render :juggernaut => { :type => :send_to_channel, :channel => puzzle.round.hunt.chat_id } do |page|
        page << "$('#{puzzle.t_id}').update('#{javascript_escape txt}');"
      end
      txt = render_to_string :partial => "info", :locals => { :puzzle => puzzle }
      render :juggernaut => { :type => :send_to_channel, :channel => puzzle.chat_id } do |page|
        page << "$('info').update('#{javascript_escape txt}');"
      end
      if (broad)
        render :juggernaut => { :type => :send_to_all } do |page|
          page << "jug_chat_update('<li>#{h Time.now.strftime("%H:%M")} <b>MAYHEM BROADCAST</b> <font style=#{ javascript_escape("'color: red;'")}>Puzzle #{h puzzle.name} in Round #{h javascript_escape puzzle.round.name} was solved with answer #{h javascript_escape puzzle.answer}</font></li>');"
        end
      end
    end
  end

  def set_worker(puzzle,worker)
    return if worker.nil?
    puzzle.workers ||= {}
    puzzle.workers[worker.login] = 1
    puzzle.save
    worker.puzzle_id = puzzle.id
    worker.save
  end
end
