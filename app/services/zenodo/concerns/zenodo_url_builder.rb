# frozen_string_literal: true

module Zenodo::Concerns::ZenodoUrlBuilder
  extend ActiveSupport::Concern

  def record_url
    raise 'record_id is missing' unless record_id

    FluentUrl.new(zenodo_url)
      .add_path('record')
      .add_path(record_id)
      .to_s
  end

  def file_url
    raise 'record_id is missing' unless record_id
    raise 'file_name is missing' unless file_name

    FluentUrl.new(zenodo_url)
      .add_path('record')
      .add_path(record_id)
      .add_path('files')
      .add_path(file_name)
      .to_s
  end

  def concept_url
    raise 'concept_id is missing' unless concept_id

    FluentUrl.new(zenodo_url)
      .add_path('record')
      .add_path(concept_id)
      .to_s
  end

  def deposition_url
    raise 'deposition_id is missing' unless deposition_id

    FluentUrl.new(zenodo_url)
      .add_path('deposit')
      .add_path(deposition_id)
      .to_s
  end

  def deposition_edit_url
    raise 'deposition_id is missing' unless deposition_id

    FluentUrl.new(zenodo_url)
      .add_path('deposit')
      .add_path(deposition_id)
      .to_s + '#/files'
  end

  def user_depositions_url
    FluentUrl.new(zenodo_url)
      .add_path('deposit')
      .to_s
  end
end
