# frozen_string_literal: true

module Common
  class FileUtils

    def normalize_name(name)
      name.to_s.parameterize(separator: '_')
    end

    def metadata_file(root_dir, filename)
      file_path = File.join(root_dir, normalize_name(filename))
      "#{file_path}.yml"
    end

    def unique_filename(root_dir, filename, delimiter: "_", max_attempts: 100)
      path = metadata_file(root_dir, filename)
      return filename unless File.exist?(path)

      dir       = File.dirname(filename)
      basename  = File.basename(filename, ".*")
      ext       = File.extname(filename)
      counter   = 1

      while counter <= max_attempts
        new_filename = File.join(dir, "#{basename}#{delimiter}#{counter}#{ext}")
        new_path =  metadata_file(root_dir, new_filename)
        return new_filename unless File.exist?(new_path)
        counter += 1
      end

      raise "Unable to generate unique metadata file for: #{filename} after #{max_attempts} attempts"
    end
  end
end