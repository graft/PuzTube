class Asset < ActiveRecord::Base
  belongs_to :workspace
  has_attached_file :file, :styles => { :thumb => "20x20>" },
                :url  => "/uploads/:basename_:id_:style.:extension",
                :path => ":rails_root/public/uploads/:basename_:id_:style.:extension"
  before_post_process :image?
  def image?
    !(file_content_type =~ /^image.*/).nil?
  end
  def mp3?
    !(file_content_type =~ /audio\/(mpeg|mpg|x-mpeg|mp3|x-mp3|mpeg3)/).nil?
  end
  before_post_process :forbid_pdf  # should be placed after line with has_attached_file 

  validates_attachment_presence :file
  validates_attachment_size :file, :less_than => 10.megabytes

  def destroy_attached_files
    true
  end 
  
  def icon
    # types we care about - audio, video
    case file.content_type
    when /^image/
      file.url(:thumb)
    when /zip/
      icon_img :zip
    when /audio\/(mpeg|mpg|x-mpeg|mp3|x-mp3|mpeg3)/
      icon_img :mp3
    when /audio\//
      icon_img :audio
    when /video\/(avi|msvideo|x-msvideo)/
      icon_img :avi
    when /application\/(octet-stream|x-octet-stream)/
      icon_img :bin
    when /application\/(doc|msword)/
      icon_img :doc
    when /(application|text)\/(pdf|x-pdf)/
      icon_img :pdf
    when /text\//
      icon_img :txt
    when /application\/(xls|excel)/
      icon_img :xls
    else
      icon_img :file
    end
  end

  private
  def icon_img type
    "/images/icon_#{type}.png"
  end

  def forbid_pdf
    return false if (file_content_type =~ /application\/.*pdf/)
  end
end
