require 'date'

module DateTools

def self.convert_epoch(epoch)
  date_time = Time.at(epoch).to_datetime  
end

def self.date_diff(epoch,file_date)
  filedate = Date.parse(file_date)
  timestamp = convert_epoch(epoch)
  timestamp = timestamp.strftime('%d/%m/%Y') 
  timestamp =  Date.parse(timestamp)
  filedate.mjd - timestamp.mjd
end

end
