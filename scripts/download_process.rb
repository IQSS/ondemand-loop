#!/usr/bin/env ruby
require_relative "../config/environment"  # Load Rails environment

download_service = Download::DownloadService.new(Download::DownloadFilesProvider.new)
download_service.start
