class Asset < ActiveRecord::Base
  belongs_to :workspace
  has_attached_file :file, :styles => { :thumb => "20x20>" },
                :url  => "/uploads/:basename_:style.:extension",
                :path => ":rails_root/public/uploads/:basename_:style.:extension"
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
    ct = file.content_type;
    return file.url(:thumb) if (ct =~ /^image/)
    return '/images/icon_zip.png' if (ct =~ /zip/)
    return '/images/icon_mp3.png' if (ct =~ /audio\/(mpeg|mpg|x-mpeg|mp3|x-mp3|mpeg3)/)
    return '/images/icon_audio.png' if (ct =~ /audio\//)
    return '/images/icon_avi.png' if (ct =~ /video\/(avi|msvideo|x-msvideo)/)
    return '/images/icon_bin.png' if (ct =~ /application\/(octet-stream|x-octet-stream)/)
    return '/images/icon_doc.png' if (ct =~ /application\/(doc|msword)/)
    return '/images/icon_pdf.png' if (ct =~ /(application|text)\/(pdf|x-pdf)/)
    return '/images/icon_txt.png' if (ct =~ /text\//)
    return '/images/icon_xls.png' if (ct =~ /application\/(xls|excel)/)
    '/images/icon_file.png'
  end

  private
  def forbid_pdf
    return false if (file_content_type =~ /application\/.*pdf/)
  end
end
