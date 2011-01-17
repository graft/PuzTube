  require 'differ'
module NiceHtml
  class << self
    def format(change)
      (change.change? && as_change(change)) ||
      (change.delete? && as_delete(change)) ||
      (change.insert? && as_insert(change)) ||
      ''
    end

  private
    def as_insert(change)
      "+#{change.insert.inspect}"
    end

    def as_delete(change)
      "-#{change.delete.inspect}"
    end

    def as_change(change)
      "-#{change.delete.inspect}\n+#{change.insert.inspect}"
    end
  end
end

module Differ
  class Diff
    def format_as(f)
      f = Differ.format_for(f)
      @raw.inject('') do |sum, part|
        part = case part
        when String then ''
        when Change then f.format(part)
        end
        sum << part
      end
    end
  end
end
module WorkspaceHelper
  def diff_html(current,original)
    diff = Differ.diff_by_line(current,original)
    diff.format_as(NiceHtml)
  end

  def relative_time(start_time)
    diff_seconds = (Time.now.getutc - start_time.getutc).to_i
    case diff_seconds
      when 0 .. 59
        "#{diff_seconds} seconds ago"
      when 60 .. (3600-1)
        "#{diff_seconds/60} minutes ago"
      when 3600 .. (3600*24-1)
        "#{diff_seconds/3600} hours ago"
      when (3600*24) .. (3600*24*30) 
        "#{diff_seconds/(3600*24)} days ago"
      else
        start_time.strftime("%m/%d/%Y")
    end
  end
end
