module Dataverse
  class DataverseMetadata < ApplicationDiskRecord

    attr_accessor :id, :hostname, :port, :scheme

    def full_name
      "#{scheme}://#{hostname}:#{port}"
    end

    def self.all
      Dir.glob(File.join(metadata_directory, "*.yml")).map do |file|
        load_from_file(file)
      end.compact
    end

    def self.find_by_uri(uri)
      full_name = uri.scheme + "://" + uri.hostname + ":" + uri.port.to_s
      find_by_full_name(full_name)
    end

    def self.find_by_full_name(full_name)
      all.find { |host| host.full_name == full_name }
    end

    def self.find(id)
      filename = filename_by_id(id)
      return nil unless File.exist?(filename)

      load_from_file(filename)
    end

    def self.find_or_initialize_by_uri(uri)
      host = find_by_uri(uri)
      return host if host

      new_host = new.tap do |h|
        h.id = DataverseMetadata.generate_id
        h.hostname = uri.hostname
        h.port = uri.port
        h.scheme = uri.scheme
      end
      new_host.save
      new_host
    end

    def to_hash
      { "id" => id, "hostname" => hostname, "port" => port, "scheme" => scheme }
    end

    def to_json
      to_hash.to_json
    end

    def to_yaml
      to_hash.to_yaml
    end

    def to_s
      to_json
    end

    def save
      FileUtils.mkdir_p(DataverseMetadata.metadata_directory)
      filename = DataverseMetadata.filename_by_id(id)
      File.open(filename, "w") do |file|
        file.write(to_yaml)
      end
      true
    end

    private

    def self.metadata_directory
      metadata_root_directory + Configuration.dataverse_metadata_folder
    end

    def self.filename_by_id(id)
      metadata_directory + "/#{id}.yml"
    end

    def self.load_from_file(filename)
      data = YAML.safe_load(File.read(filename), permitted_classes: [Hash], aliases: true)
      new.tap do |host|
        host.id = data["id"]
        host.hostname = data["hostname"]
        host.port = data["port"]
        host.scheme = data["scheme"]
      end
    rescue StandardError
      nil
    end

  end
end