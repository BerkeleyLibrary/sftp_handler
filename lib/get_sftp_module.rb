require 'net/sftp'
require 'net/ssh'
module GetSFTP  

def self.get_connection()
  host = 'ftp.ybp.com'
  user = 'berkeley'
  password = 'tR6s5t' 

  sftp = Net::SFTP.start(host,user,{password: password,port: 22,append_all_supported_algorithms: true},sftp_options={:version=>3})

end

def self.download_file(conn,remote_file,local_file)
  conn.download!(remote_file,local_file)
end

def self.get_dir_filenames(conn,dir)
  files = [] 
  conn.dir.foreach(dir) do |entry| 
    files << entry
  end
  files
end

def self.get_filename(fh)
  fh.name
end

def self.get_timestamp(fh)
  fh.attributes.mtime
end

#Net::SFTP.start(host,user,{password: password,port: 22,append_all_supported_algorithms: true},sftp_options={:version=>3}) do |sftp|
#  sftp.dir.foreach("gobiord") do |entry| 
#    if entry.name.match(/ebook.*?\.ord/)
#     puts entry.name
#     puts entry.attributes.mtime
#     puts Time.at(entry.attributes.mtime)
#    end
#  end
###  sftp.download!("/gobiord/ebook1223.ord", "ebook1223.ord")
#end

end
