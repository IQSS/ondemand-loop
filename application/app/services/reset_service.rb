# frozen_string_literal: true

require 'fileutils'

# ResetService - TEMPORARY Beta-Only Feature
#
# This service provides a nuclear reset option for OnDemand Loop during the beta phase.
# It's designed to help users recover from backwards-incompatible changes by completely
# wiping all application state and metadata.
#
# ⚠️ WARNING: This is a destructive operation that:
#   - Shuts down all background processing (downloads/uploads)
#   - Deletes all project metadata
#   - Removes all repository configurations
#   - Clears user settings
#
# 🗑️ DEPRECATION NOTICE:
#   This class is TEMPORARY and will be removed when the application reaches stable release.
#   Once we achieve backwards compatibility guarantees, this reset mechanism will no longer
#   be necessary and should be removed from the codebase.
#
# Usage:
#   This service is invoked via the web UI reset button, which is only available during beta.
#   The reset action requires a POST request for safety.
#
class ResetService
  include LoggingCommon

  # Maximum time to wait for detached process to shut down (in seconds)
  SHUTDOWN_TIMEOUT = 5
  # Time to sleep between shutdown checks (in seconds)
  SHUTDOWN_CHECK_INTERVAL = 1

  def reset_request_allowed?(request)
    # ONLY CONDITION IS THAT THE REQUEST IS A POST
    request.post?
  end

  # Performs a complete reset of the application state
  #
  # Steps:
  #   1. Request shutdown of detached background process
  #   2. Wait for shutdown to complete
  #   3. Clean up process control files (socket, lock)
  #   4. Delete all metadata directories and files
  #
  # @raise [StandardError] if reset fails at any step
  def reset
    log_info('Resetting...')

    # Capture paths early for error logging
    metadata_root = Configuration.metadata_root
    detached_process_lock = Configuration.detached_process_lock_file
    command_server_socket = Configuration.command_server_socket_file

    # Step 1: Request shutdown of detached process (if running)
    shutdown_detached_process(command_server_socket, detached_process_lock)

    # Step 2: Clean up process control files
    cleanup_process_files(detached_process_lock, command_server_socket)

    # Step 3: Delete all metadata
    delete_metadata(metadata_root)

    log_info('Reset completed successfully')
  rescue StandardError => e
    log_error('Failed to reset application state', {
      metadata_root: metadata_root,
      detached_process_lock: detached_process_lock,
      command_server_socket: command_server_socket
    }, e)
    raise
  end

  private

  def shutdown_detached_process(socket_path, lock_file)
    unless File.exist?(socket_path)
      log_info('Detached process not running (socket not found)', { socket: socket_path })
      return
    end

    log_info('Requesting detached process shutdown...')
    command_client = Command::CommandClient.new(socket_path: socket_path)
    request = Command::Request.new(command: 'detached.process.shutdown')
    response = command_client.request(request, timeout: 2)
    log_info('Shutdown response received', { status: response.status, body: response.body })

    # Wait for shutdown to complete by monitoring the lock file
    wait_for_shutdown(lock_file)
  rescue => e
    log_error('Shutdown request error', { socket: socket_path }, e)
    # Continue anyway - we'll clean up the files
  end

  def wait_for_shutdown(lock_file)
    elapsed = 0
    while File.exist?(lock_file) && elapsed < SHUTDOWN_TIMEOUT
      sleep SHUTDOWN_CHECK_INTERVAL
      elapsed += SHUTDOWN_CHECK_INTERVAL
    end

    if File.exist?(lock_file)
      log_info('Shutdown wait timed out, forcing cleanup', { timeout: SHUTDOWN_TIMEOUT, lock_file: lock_file })
    else
      log_info('Detached process shutdown confirmed', { elapsed: elapsed, lock_file: lock_file })
    end
  end

  def cleanup_process_files(lock_file, socket_file)
    log_info('Cleaning up process control files', { lock_file: lock_file, socket_file: socket_file })

    FileUtils.rm_f(socket_file)
    FileUtils.rm_f(lock_file)

    log_info('Process control files cleaned up')
  end

  def delete_metadata(metadata_root)
    projects_root = Project.metadata_directory
    repos_root = File.join(metadata_root, 'repos')
    user_settings = File.join(metadata_root, 'user_settings.yml')

    log_info('Deleting metadata folders/files', {
      projects_root: projects_root,
      user_settings: user_settings
    })

    # Use rm_rf for directories (recursive delete)
    FileUtils.rm_rf(projects_root) if File.exist?(projects_root)
    FileUtils.rm_rf(repos_root) if File.exist?(repos_root)

    # Use rm_f for files (ignore if doesn't exist)
    FileUtils.rm_f(user_settings)

    log_info('Metadata deletion completed')
  end
end
