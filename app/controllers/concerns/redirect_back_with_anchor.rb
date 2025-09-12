
module RedirectBackWithAnchor
  extend ActiveSupport::Concern

  included do
    private

    def redirect_back(fallback_location:, allow_other_host: false, **args)
      referer = request.referer
      url = referer.presence || fallback_location

      anchor = params[:anchor].to_s.strip
      url = append_anchor(url, anchor) if anchor.present?

      redirect_to url, allow_other_host: allow_other_host, **args
    end

    def append_anchor(url, anchor)
      uri = URI.parse(url)
      uri.fragment = anchor
      uri.to_s
    rescue URI::InvalidURIError
      url
    end
  end
end
