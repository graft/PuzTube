# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def javascript_escape(str)
    str.gsub(/\\|'/) { |c| "\\#{c}" }.gsub(/\n/,' ')
  end
  
  def sanitize_text(str)
    sanitize(auto_link(str, :html => { :target => '_blank' }), :tags => %w(a), :attributes => %w(href target) )
  end
  
  
  def comment_format(str)
    str.gsub(/\n/,'<br>') # also replace COMMA/ENDCOMMA stuff
  end
end
