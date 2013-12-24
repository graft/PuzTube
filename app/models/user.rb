class User < ActiveRecord::Base
  serialize :options
  after_initialize :set_default_options
  validates_uniqueness_of :login
  belongs_to :puzzle
  has_many :recent_activities, :class_name => "Activity", :order => "created_at DESC", :limit => 20
  has_attached_file :photo, :styles => {
	  		:thumb => "60x60>"
  		},
		:url  => "/uploads/:basename_:id_:style.:extension",
		:path => ":rails_root/public/uploads/:basename_:id_:style.:extension"
  validates_attachment_size :photo, :less_than => 1.megabyte
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  attr_accessible :login, :name, :email, :info
  
  def set_default_options
    options ||= { :sorting => "status", :grouped => false }
  end

  def active?
    updated_at > Time.utc(2011,12)
  end

  def self.list
    self.all(:order => "login ASC").collect{|u| [u.login,u.login] }
  end
end
