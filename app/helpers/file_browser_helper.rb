# frozen_string_literal: true

module FileBrowserHelper

  def browser_entry_icon(entry)
    return 'bi-folder-fill' if entry.folder?
    return 'bi-file-earmark' if entry.file?

    'bi-slash-circle'
  end
end