#!/usr/bin/env ruby
require_relative "../config/environment"  # Load Rails environment

upload_process = Upload::UploadProcess.new
upload_process.launch
