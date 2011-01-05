module PuzzlesHelper
  def javascript_escape(str)
    str.gsub(/\\|'/) { |c| "\\#{c}" }
  end
  
  def sanitize_text(str)
    sanitize(auto_link(str, :html => { :target => '_blank' }), :tags => %w(a), :attributes => %w(href target) )
  end
end
