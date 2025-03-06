class DataverseHost < ApplicationDiskRecord

  attr_accessor :id, :hostname, :port, :scheme

  def full_name
    "#{scheme}://#{hostname}:#{port}"
  end
  def self.all
    [] #TODO
  end

  def self.find_by_uri(uri)
    full_name = uri.scheme + "://" + uri.hostname + ":" + uri.port.to_s
    self.find_by_full_name(full_name)
  end
  def self.find_by_full_name(full_name)
    [] #TODO
  end

  def self.find(id)
    nil #TODO
  end


  def to_hash
    { id: id, hostname: hostname, port: port, scheme: scheme, full_name: full_name }
  end

  def to_json
    to_hash.to_json
  end
  def to_s
    to_json.to_s
  end
  def save
    true #TODO
  end
end