require 'net/ftp'
class PdfDelivery < ActiveRecord::Base
  
  belongs_to :registrant
  
  def generate_pdf!
    generate_pdf(true)
  end
  
  def generate_pdf(force = false)
    if registrant.pdf_writer.valid?
      if registrant.pdf_writer.generate_pdf(force, true)
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def finalize_pdf
    self.pdf_ready = true
    save(validate: false)
  end
  
  
  def self.store_in_s3(path, url_path)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
    bucket_name = "rocky-pdfs#{Rails.env.production? ? '' : "-#{Rails.env}"}"
    directory = connection.directories.get(bucket_name)
    date_stamp = Date.today.strftime("%Y-%m-%d")
    file = directory.files.create(
      :key    => "redacted/#{date_stamp}/#{url_path.gsub(/^\//,'')}",
      :body   => File.open(path).read,
      :content_type => "application/pdf",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => true
    ) 
  rescue Exception=>e
    raise e
    
    return false   
  end
  
  # URL is ftp.garnerprint.com
  # User name:whenwevote
  # Password: redfq86#
  def self.transfer(local_path)
    #file_name = 
    
    port = 21
    ftp = Net::FTP.new  # don't pass hostname or it will try open on default port
    ftp.connect('ftp.garnerprint.com', port)  # here you can pass a non-standard port number
    ftp.passive = true
    ftp.login('whenwevote', 'redfq86#')
    files = ftp.list('*')
    puts files
    ftp.close
    
    # Net::FTP.open('ftp.garnerprint.com') do |ftp|
    #   ftp.login('whenwevote', 'redfq86#')
    #   files = ftp.list('*')
    #   puts files
    #   #ftp.getbinaryfile('nif.rb-0.91.gz', 'nif.gz', 1024)
    # end
    
    
  end
  
end
