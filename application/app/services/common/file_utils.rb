# frozen_string_literal: true

module Common
  class FileUtils
    include LoggingCommon

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
      root_dir = Project.download_files_directory(download_file.project_id)
      download_file.filename = unique_filename(root_dir, download_file.filename)
      download_file.id = normalize_name(download_file.filename)
      download_file
    end

    def move_all(source_dir, destination_dir)
      return if source_dir.to_s == destination_dir.to_s

      return unless Dir.exist?(source_dir)

      log_info('Move directory contents', { source: source_dir, destination: destination_dir })

      begin
        ::FileUtils.mkdir_p(destination_dir)
        ::FileUtils.mv(Dir["#{source_dir}/*"], destination_dir)
        ::FileUtils.rmdir(source_dir) if Dir.exist?(source_dir) && Dir.empty?(source_dir)
      rescue => e
        log_error('Move directory contents error', { source: source_dir, destination: destination_dir }, e)
        raise
      end
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
