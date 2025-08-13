# frozen_string_literal: true

module Zenodo::Concerns::ZenodoUrlBuilder
  extend ActiveSupport::Concern

  def record_url
    raise 'record_id is missing' unless record_id

    FluentUrl.new(zenodo_url)
      .add_path('records')
      .add_path(record_id.to_s)
      .to_s
  end

  def file_url
    raise 'record_id is missing' unless record_id
    raise 'file_name is missing' unless file_name

    FluentUrl.new(zenodo_url)
      .add_path('records')
      .add_path(record_id.to_s)
      .add_path('files')
      .add_path(file_name)
      .to_s
  end

  def deposition_url
    raise 'deposition_id is missing' unless deposition_id

    FluentUrl.new(zenodo_url)
      .add_path('uploads')
      .add_path(deposition_id.to_s)
      .to_s
  end

  def user_depositions_url
    FluentUrl.new(zenodo_url)
      .add_path('me')
      .add_path('uploads')
      .to_s
  end
end
