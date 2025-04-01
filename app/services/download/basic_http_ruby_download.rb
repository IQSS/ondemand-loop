# frozen_string_literal: true
module Download
  # Utility class to download a file from an HTTP url.
  # It downloads the file in chunks to be memory efficient.
  # It supports stopping the download at any point.
  class BasicHttpRubyDownload
    include LoggingCommon

    attr_reader :download_url, :download_file, :temp_file

    def initialize(download_url, download_file, temp_file)
      @download_url = download_url
      @download_file = download_file
      @temp_file = temp_file
    end

    def download
      log_info('Downloading...', {url: download_url, file: download_file, temp: temp_file})
      download_follow_redirects(download_url, temp_file)
      FileUtils.mv(temp_file, download_file)
    ensure
      File.delete(temp_file) if File.exist?(temp_file)
    end

    private

    def download_follow_redirects(url, file_path, headers = {}, limit = 3)
      raise "Too many redirects" if limit <= 0

      uri = URI.parse(url)
      request = Net::HTTP::Get.new(uri, headers)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request) do |response|
          if redirect?(response)
            new_url = URI.join(url, response['location']).to_s
            log_info('Redirect...', {url: new_url, file: download_file, temp: temp_file})
            return download_follow_redirects(new_url, file_path, headers, limit - 1)
          end

          raise "Failed to download: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

          File.open(file_path, "wb") do |file|
            response.read_body { |chunk| file.write(chunk) } # Stream chunks
          end
        end
      end

    end

    def redirect?(response)
      response.is_a?(Net::HTTPRedirection) && response['location']
    end

  end
end
