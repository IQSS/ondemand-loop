# frozen_string_literal: true

require 'fileutils'

# ResetService removes the application metadata directory.
class ResetService
  include LoggingCommon

  # Deletes the metadata root directory configured for the application.
  def reset
    log_info('Resetting...')
    metadata_root = Configuration.metadata_root
    detached_process_lock = Configuration.detached_process_lock_file
    command_server_socket = Configuration.command_server_socket_file
    log_info('Deleting metadata files', { root: metadata_root, detached_process_lock: detached_process_lock, command_server_socket: command_server_socket })
    FileUtils.rm_f(command_server_socket)
    FileUtils.rm_f(detached_process_lock)
    FileUtils.rm_rf(metadata_root)
    log_info('Reset completed')
  rescue StandardError => e
    log_error('Failed to reset application state', { root: metadata_root, detached_process_lock: detached_process_lock, command_server_socket: command_server_socket }, e)
    raise
  end
end