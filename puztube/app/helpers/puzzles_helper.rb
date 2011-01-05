module PuzzlesHelper
  def javascript_escape(str)
    str.gsub(/\\|'/) { |c| "\\#{c}" }
  end
end
