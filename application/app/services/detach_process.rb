# frozen_string_literal: true

class DetachProcess
  SCRIPT = 'scripts/download_process.rb'

  def start_process
    ruby_binary = Configuration.ruby_binary
    script_log_file = File.join(Configuration.metadata_root, 'download_service.log')
    pid = Process.spawn(
      ruby_binary,
      DetachProcess::SCRIPT,
      out: [script_log_file, 'a'],
      err: [script_log_file, 'a'],
      in: '/dev/null',
      pgroup: true
    )
    Process.detach(pid)
  end

  # TODO: We need a status page to show the detached service execution logs and possibly other things
  def start_process_bak
    script_log_file = File.join(Configuration.metadata_root, 'download_service.log')
    ruby_binary = Configuration.ruby_binary
    system("nohup #{ruby_binary} #{DetachProcess::SCRIPT} >> #{script_log_file} 2>&1 &")
  end
end