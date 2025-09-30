#!/usr/bin/env ruby
require_relative "../config/environment"  # Load Rails environment

Rails.logger = LoggingCommon.create_logger('loop_process.log')

detached_process = DetachedProcess.new
detached_process.launch


