class User < ActiveRecord::Base
  serialize :options
  after_initialize :set_default_options
  validates_uniqueness_of :login
  belongs_to :puzzle
  has_attached_file :photo, :styles => {
	  		:thumb => "60x60>"
  		},
		:url  => "/uploads/:basename_:id_:style.:extension",
		:path => ":rails_root/public/uploads/:basename_:id_:style.:extension"
  validates_attachment_size :photo, :less_than => 1.megabyte
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  
  def set_default_options
    self.options ||= { :sorting => "status", :grouped => false }
  end
end
