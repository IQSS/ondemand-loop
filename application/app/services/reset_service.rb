# frozen_string_literal: true

require 'fileutils'

# ResetService removes the application metadata directory.
class ResetService
  include LoggingCommon

  # Deletes the metadata root directory configured for the application.
  def reset
    metadata_root = Configuration.metadata_root
    log_info('Deleting metadata directory', path: metadata_root)
    FileUtils.rm_rf(metadata_root)
    log_info('Deleted metadata directory', path: metadata_root)
  rescue StandardError => e
    log_error('Failed to delete metadata directory', { path: metadata_root }, e)
    raise
  end
end