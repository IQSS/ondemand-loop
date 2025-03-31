# frozen_string_literal: true
# TODO: spawn and detach does not work on my local environment. Check with David
class DetachProcess
  SCRIPT = 'scripts/download_process.rb'
  def start_process_bak
    ruby_binary = Configuration.ruby_binary
    pid = spawn('sh', '-c', 'nohup', ruby_binary, DetachProcess::SCRIPT, out: "/tmp/out.txt", err: "/tmp/err.txt")
    Process.detach(pid)
  end

  # TODO: We need a status page to show the detached service execution logs and possibly other things
  def start_process
    script_log_file = File.join(Configuration.metadata_root, 'download_service.log')
    ruby_binary = Configuration.ruby_binary
    system("nohup #{ruby_binary} #{DetachProcess::SCRIPT} >> #{script_log_file} 2>&1 &")
  end
end