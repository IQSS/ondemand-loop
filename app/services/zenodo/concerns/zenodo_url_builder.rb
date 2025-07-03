# frozen_string_literal: true

module Zenodo::Concerns::ZenodoUrlBuilder
  extend ActiveSupport::Concern

  def record_url
    raise 'record_id is missing' unless record_id

    "#{zenodo_url}/record/#{record_id}"
  end

  def file_url
    raise 'record_id is missing' unless record_id
    raise 'file_name is missing' unless file_name

    "#{zenodo_url}/record/#{record_id}/files/#{file_name}"
  end

  def concept_url
    raise 'concept_id is missing' unless concept_id

    "#{zenodo_url}/record/#{concept_id}"
  end

  def deposition_url
    raise 'record_id is missing' unless deposition_id

    "#{zenodo_url}/deposit/#{deposition_id}"
  end

  def deposition_edit_url
    raise 'record_id is missing' unless deposition_id

    "#{zenodo_url}/deposit/#{deposition_id}#/files"
  end

  def user_depositions_url
    "#{zenodo_url}/deposit"
  end
end
