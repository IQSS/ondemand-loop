# frozen_string_literal: true

class ScriptLauncher
  include LoggingCommon
  LAUNCH_SCRIPT = 'scripts/launch_detached_process.rb'

  def initialize(download_files_provider, upload_files_provider)
    @download_files_provider = download_files_provider
    @upload_files_provider = upload_files_provider
  end

  def launch_script
    if pending_files?
      start_process_from_script(LAUNCH_SCRIPT, 'launch_detached_process.log')
    else
      log_info("No pending files - skipping")
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
  end
end