# frozen_string_literal: true

class ScriptLauncher
  include LoggingCommon
  include DateTimeCommon
  LAUNCH_SCRIPT = 'scripts/launch_detached_process.rb'

  def initialize(download_files_provider, upload_files_provider)
    @download_files_provider = download_files_provider
    @upload_files_provider = upload_files_provider
  end

  def launch_script
    return log_info('No pending files - skipping') unless pending_files?

    lock_file = Configuration.detached_process_lock_file
    File.open(lock_file, File::CREAT | File::RDWR) do |service_lock|
      if service_lock.flock(File::LOCK_EX | File::LOCK_NB)
        if process_already_running?(service_lock)
          log_info('Skip. DetachedProcess already running', { lock_file: lock_file })
        else
          log_info("Launching Detached Process Script...", { lock_file: lock_file })
          spawn_pid = start_process_from_script(LAUNCH_SCRIPT, 'launch_detached_process.log')

          # Write PID and timestamp to lock file while we have the lock
          update_lock_file(service_lock, spawn_pid)

          log_info("DetachedProcess started", { pid: spawn_pid, lock_file: lock_file, started_at: now })
        end
      else
        log_info('Skip. Another request is processing the lock', { lock_file: lock_file })
      end
    end
  end

  def pending_files?
    @download_files_provider.pending_files.any? || @upload_files_provider.pending_files.any?
  end

  # TODO: We need a status page to show the detached service execution logs and possibly other things
  def start_process_from_script(script_name, script_log)
    ruby_binary = Configuration.ruby_binary
    script_log_file = File.join(Configuration.metadata_root, script_log)
    pid = Process.spawn(
      ruby_binary,
      script_name,
      out: [script_log_file, 'a'],
      err: [script_log_file, 'a'],
      in: '/dev/null',
      pgroup: true
    )
    Process.detach(pid)
    pid
  end

  private

  def process_already_running?(file)
    file.rewind
    content = file.read.strip
    return false if content.empty?

    lines = content.split("\n")
    return false if lines.length < 2

    pid = lines[0].to_i
    timestamp_str = lines[1].strip
    timestamp = to_time(timestamp_str)

    # GIVE TIME FOR THE DETACHED PROCESS TO START
    # ONLY CHECK PROCESS IF AT LEAST 60s HAS ELAPSED
    return true if elapsed(timestamp) < 60

    # Check if process actually exists
    begin
      Process.getpgid(pid)
      log_info("Found running DetachedProcess", {
        pid: pid,
        started_at: timestamp_str,
        running_for: elapsed_string(timestamp)
      })
      true
    rescue Errno::ESRCH
      log_info("Stale lock file detected - process no longer exists", {
        pid: pid,
        was_started_at: timestamp_str,
        was_running_for: elapsed_string(timestamp)
      })
      false
    rescue => e
      log_warn("Error checking process status", { pid: pid, error: e.message })
      false
    end
  end

  def update_lock_file(file, pid)
    file.rewind
    file.write("#{pid}\n#{now}")
    file.flush
    file.truncate(file.pos)
  rescue => e
    log_error("Failed to update lock file", { pid: pid, error: e.message })
    raise
  end
end
