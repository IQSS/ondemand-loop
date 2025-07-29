# frozen_string_literal: true

require 'test_helper'

class Zenodo::UploadBundleConnectorMetadataTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
  end

  def build_meta(metadata = {})
    bundle = create_upload_bundle(@project)
    bundle.metadata = metadata
    Zenodo::UploadBundleConnectorMetadata.new(bundle)
  end

  test 'responds to dynamic metadata methods' do
    meta = build_meta({ title: 'Test Title', draft: true, auth_key: 'abc123' })
    assert_equal 'Test Title', meta.title
    assert_equal true, meta.draft
    assert_equal 'abc123', meta.auth_key
  end

  test 'to_h converts keys to strings' do
    meta = build_meta({ title: 'Value', other_key: 1 })
    result = meta.to_h
    assert_equal 'Value', result['title']
    assert_equal 1, result['other_key']
    assert result.keys.all? { |k| k.is_a?(String) }
  end

  test 'api_key returns bundle value if present' do
    meta = build_meta({ auth_key: 'key123' })
    key = meta.api_key
    assert key.bundle?
    assert_not key.server?
    assert_equal 'key123', key.value
  end

  test 'api_key falls back to repo registry if auth_key not in metadata' do
    fake_key = 'from_repo'
    mock_repo_info = stub(metadata: stub(auth_key: fake_key))
    RepoRegistry.repo_db.stubs(:get).returns(mock_repo_info)

    meta = build_meta({ zenodo_url: 'https://zenodo.org' })
    key = meta.api_key
    assert_not key.bundle?
    assert key.server?
    assert_equal fake_key, key.value
  end

  test 'api_key returns nil if no key is present anywhere' do
    RepoRegistry.repo_db.stubs(:get).returns(nil)
    meta = build_meta({ zenodo_url: 'https://zenodo.org' })
    assert_nil meta.api_key
    refute meta.api_key?
  end

  test 'display_title? returns true if title present' do
    meta = build_meta({ title: 'Some Title' })
    assert meta.display_title?
  end

  test 'display_title? returns false if title is nil' do
    meta = build_meta({})
    refute meta.display_title?
  end

  test 'title_url prefers deposition_id, then record_id, then zenodo_url' do
    meta = build_meta({ zenodo_url: 'https://zenodo.org', deposition_id: 123 })
    assert_equal 'https://zenodo.org/uploads/123', meta.title_url

    meta = build_meta({ zenodo_url: 'https://zenodo.org', record_id: 456 })
    assert_equal 'https://zenodo.org/record/456', meta.title_url

    meta = build_meta({ zenodo_url: 'https://zenodo.org' })
    assert_equal 'https://zenodo.org', meta.title_url
  end

  test 'fetch_deposition? requires api_key, no draft, and deposition_id' do
    meta = build_meta({ auth_key: 'abc', deposition_id: 1 })
    assert meta.fetch_deposition?
  end

  test 'create_draft? requires api_key, no draft, no deposition_id, and record_id present' do
    meta = build_meta({ auth_key: 'abc', record_id: 42 })
    assert meta.create_draft?
  end

  test 'draft? returns true if draft present and truthy' do
    meta = build_meta({ draft: true })
    assert meta.draft?
  end

  test 'api_key_required? returns true if no api key and draft nil' do
    RepoRegistry.repo_db.stubs(:get).returns(nil)
    meta = build_meta({ zenodo_url: 'https://zenodo.org' })
    assert meta.api_key_required?
  end

  test 'method_missing returns nil for undefined methods' do
    meta = build_meta({ })
    assert_nil meta.undefined_key
  end
end
