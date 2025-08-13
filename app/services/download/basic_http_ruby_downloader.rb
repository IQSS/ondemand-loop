# frozen_string_literal: true
module Download
  # Utility class to download a file from an HTTP url.
  # It downloads the file in chunks to be memory efficient.
  # It supports cancelling the download at any point.
  class BasicHttpRubyDownloader
    include LoggingCommon

    attr_reader :download_url, :download_file, :temp_file, :headers, :partial_downloads

    def initialize(download_url, download_file, temp_file, headers: {})
      @download_url = download_url
      @download_file = download_file
      @temp_file = temp_file
      @headers = headers
      @partial_downloads = nil
    end

    def download(&)
      log_info('Downloading...', {url: download_url, file: download_file, temp: temp_file})
      resume_from = File.exist?(temp_file) ? File.size(temp_file) : 0
      request_headers = headers.dup
      request_headers['Range'] = "bytes=#{resume_from}-" if resume_from.positive?
      cancelled = download_follow_redirects(download_url, temp_file, request_headers, 3, resume_from, &)
      FileUtils.mv(temp_file, download_file) unless cancelled
    end

    private

    def download_follow_redirects(url, file_path, headers = {}, limit = 3, total_downloaded = 0, &)
      raise "Too many redirects" if limit <= 0

      uri = URI.parse(url)
      request = Net::HTTP::Get.new(uri, headers)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request) do |response|
          if redirect?(response)
            new_url = URI.join(url, response['location']).to_s
            log_info('Redirect...', {url: new_url, file: download_file, temp: temp_file})
            return download_follow_redirects(new_url, file_path, headers, limit - 1, total_downloaded, &)
          end

          raise "Failed to download: (HTTP: #{response.code}) #{response.body}" unless response.is_a?(Net::HTTPSuccess)

          @partial_downloads = supports_range?(response) if @partial_downloads.nil?
          total_downloaded = 0 if total_downloaded.positive? && !@partial_downloads

          log_info("Restarting Download from: #{download_file}") if total_downloaded.positive?

          mode = total_downloaded.positive? ? "ab" : "wb"
          File.open(file_path, mode) do |file|
            response.read_body do |chunk|
              file.write(chunk)
              total_downloaded += chunk.length
              if block_given?
                # THE CALLER WANTS TO HANDLE CANCELLATIONS
                cancel = yield create_context(url, file_path, total_downloaded)
                if cancel
                  log_info('Download canceled.', {url: url, file: download_file, temp: temp_file})
                  return true
                end
              end
            end
          end
        end
      end

      false
    end

    def redirect?(response)
      response.is_a?(Net::HTTPRedirection) && response['location']
    end

    def create_context(url, location, total)
      {
        url: url,
        location: location,
        total: total,
        partial_downloads: @partial_downloads
      }
    end

    def supports_range?(response)
      response.code.to_i == 206 || response['accept-ranges'].to_s.downcase == 'bytes'
    end

  end
end
