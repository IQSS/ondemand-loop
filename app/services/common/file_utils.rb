# frozen_string_literal: true

module Common
  class FileUtils
    include LoggingCommon

    def zip_file?(file_path)
      return false unless File.file?(file_path)

      File.open(file_path, 'rb') do |file|
        # Read the first 4 bytes (magic number)
        signature = file.read(4)
        signature == "\x50\x4B\x03\x04"
      end
    end

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

    def move_project_downloads(project, old_dir, new_dir)
      return if old_dir.to_s == new_dir.to_s
      return unless Dir.exist?(old_dir)

      log_info('Move download files', { project_id: project.id, files: project.download_files.size, old_dir: old_dir, new_dir: new_dir })

      moved_any = false

      project.download_files.each do |file|
        relative_path = file.filename
        source_path = File.join(old_dir, relative_path)
        destination_path = File.join(new_dir, relative_path)

        unless File.exist?(source_path)
          log_info('File not found, skipping', { project_id: project.id, status: file.status, file: source_path })
          next
        end

        begin
          ::FileUtils.mkdir_p(File.dirname(destination_path))
          ::FileUtils.mv(source_path, destination_path)
          moved_any = true
        rescue => e
          log_error('Failed to move file', { project_id: project.id, status: file.status, from: source_path, to: destination_path }, e)
          # continue with next file
        end
      end

      # Try to clean up the old dir only if everything is gone
      begin
        ::FileUtils.rmdir(old_dir) if Dir.exist?(old_dir) && Dir.empty?(old_dir)
      rescue => e
        log_error('Could not remove old download_dir', { path: old_dir }, e)
      end

      moved_any
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
