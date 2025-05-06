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

      parts = parse_filename_parts(filename)
      counter   = 1

      while counter <= max_attempts
        new_filename = File.join(parts.dir, "#{parts.base}#{delimiter}#{counter}#{parts.ext}")
        new_path =  metadata_file(root_dir, new_filename)
        return new_filename unless File.exist?(new_path)
        counter += 1
      end

      raise "Unable to generate unique metadata file for: #{filename} after #{max_attempts} attempts"
    end

    def make_download_file_unique(download_file)
      root_dir = Project.files_directory(download_file.project_id)
      download_file.filename = unique_filename(root_dir, download_file.filename)
      download_file.id = normalize_name(download_file.filename)
      download_file
    end

    private
    def parse_filename_parts(filename)
      path = Pathname.new(filename)
      ext  = path.extname
      dir  = path.dirname.to_s
      base = path.basename(ext).to_s

      OpenStruct.new(
        dir: (dir == "." ? "" : dir),
        base: base,
        ext: ext
      )
    end

  end
end