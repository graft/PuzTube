module PuzzleThread
  module ClassMethods
    def is_thread?
      true
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def chat_id
    "#{self.class.name.downcase}-#{id}"
  end
end
