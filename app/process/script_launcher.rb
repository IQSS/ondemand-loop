# frozen_string_literal: true

class ScriptLauncher
  LAUNCH_SCRIPT = 'scripts/launch_detached_process.rb'

  def launch_script
    start_process_from_script(LAUNCH_SCRIPT, 'launch_detached_process.log')
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