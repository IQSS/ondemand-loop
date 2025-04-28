#!/usr/bin/env ruby
require_relative "../config/environment"  # Load Rails environment

download_process = Download::DownloadProcess.new
download_process.launch
