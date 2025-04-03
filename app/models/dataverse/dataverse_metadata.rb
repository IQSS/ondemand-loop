module Dataverse
  class DataverseMetadata < ApplicationDiskRecord

    attr_accessor :id, :hostname, :port, :scheme

    def full_hostname
      "#{scheme}://#{hostname}:#{port}"
    end

    def self.all
      Dir.glob(File.join(metadata_directory, "*.yml")).map do |file|
        load_from_file(file)
      end.compact
    end

    def self.find_by_uri(uri)
      full_hostname = uri.scheme + "://" + uri.hostname + ":" + uri.port.to_s
      find_by_full_name(full_hostname)
    end

    def self.find_by_full_name(full_hostname)
      all.find { |metadata| metadata.full_hostname == full_hostname }
    end

    def self.find(id)
      filename = filename_by_id(id)
      return nil unless File.exist?(filename)

      load_from_file(filename)
    end

    def self.find_or_initialize_by_uri(uri)
      metadata = find_by_uri(uri)
      return metadata if metadata

      new_metadata = new.tap do |m|
        m.id = DataverseMetadata.generate_id
        m.hostname = uri.hostname
        m.port = uri.port
        m.scheme = uri.scheme
      end
      new_metadata.save
      new_metadata
    end

    def self.find_or_initialize_by_full_name(full_name)
      uri = URI.parse(full_name)
      find_or_initialize_by_uri(uri)
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
      File.join(metadata_root_directory, 'dataverse-metadata')
    end

    def self.filename_by_id(id)
      File.join(metadata_directory, "#{id}.yml")
    end

    def self.load_from_file(filename)
      data = YAML.safe_load(File.read(filename), permitted_classes: [Hash], aliases: true)
      new.tap do |dataverse_metadata|
        dataverse_metadata.id = data["id"]
        dataverse_metadata.hostname = data["hostname"]
        dataverse_metadata.port = data["port"]
        dataverse_metadata.scheme = data["scheme"]
      end
    rescue StandardError
      nil
    end

  end
end