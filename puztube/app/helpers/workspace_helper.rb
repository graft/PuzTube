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
end
