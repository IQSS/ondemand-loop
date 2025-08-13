class FileBrowserController < ApplicationController
  include LoggingCommon

  def index
    path = safe_path(params[:path])

    if path.nil?
      render json: { error: t('file_browser.directory_forbidden') }, status: :forbidden
      return
    end

    current_path = path
    #TODO: Abstract file management and utilities into a new class
    entries = Dir.entries(path).reject { |e| e == '.' || e == '..' }
                  .map do |entry|
      full_path = File.join(path, entry)
      OpenStruct.new({
        name: entry,
        path: full_path,
        size: File.size(full_path),
        type: File.directory?(full_path) ? 'folder' : 'file'
      })
    end.sort_by do |f|
      [File.file?(f.path) ? 1 : 0, f.name.downcase]
    end

    render partial: "file_browser/browser", locals: { current_path: current_path, entries: entries }
  end

  private

  def safe_path(path_param)
    return Dir.home unless path_param.present?

    path = File.expand_path(path_param)
    # RETURN NIL WHEN PATH INVALID OR NOT ACCESSIBLE
    accessible_path?(path) ? path : nil
  end

  def accessible_path?(path)
    return false unless File.exist?(path)

    if File.directory?(path)
      File.readable?(path) && File.executable?(path)
    else
      File.readable?(path)
    end
  end

end
