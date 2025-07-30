module Zenodo::RecordsHelper
  DEFAULT_ZENODO_URL = 'https://zenodo.org'.freeze

  def external_record_url(record_id, zenodo_url = DEFAULT_ZENODO_URL)
    FluentUrl.new(zenodo_url).add_path('records').add_path(record_id.to_s).to_s
  end
end
