# frozen_string_literal: true

class DetachProcess
  SCRIPT = 'scripts/download_process.rb'

  # TODO: We need a status page to show the detached service execution logs and possibly other things
  def start_process
    script_log_file = File.join(Configuration.metadata_root, 'download_service.log')
    ruby_binary = Configuration.ruby_binary
    system("nohup #{ruby_binary} #{DetachProcess::SCRIPT} >> #{script_log_file} 2>&1 &")
  end
end