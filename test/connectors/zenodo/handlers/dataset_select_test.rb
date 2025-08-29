require 'test_helper'
require 'tempfile'

class Zenodo::Handlers::DatasetSelectTest < ActiveSupport::TestCase
  include ModelHelper

  class FakeUploadBundle
    attr_reader :id
    attr_accessor :metadata

    def initialize(id:, metadata: {})
      @id = id
      @metadata = metadata
    end

    def connector_metadata
      Zenodo::UploadBundleConnectorMetadata.new(self)
    end

    def update(attrs)
      @metadata.merge!(attrs[:metadata])
    end
  end

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(
      zenodo_url: 'http://zenodo.org',
      api_key: OpenStruct.new(value: 'KEY'),
      title_url: 'http://zenodo.org/title'
    )
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Zenodo::Handlers::DatasetSelect.new
  end

  test 'params schema includes deposition_id' do
    assert_includes @action.params_schema, :deposition_id
  end

  test 'edit not implemented' do
    assert_raises(NotImplementedError) { @action.edit(@bundle, {}) }
  end

  test 'update stores deposition information for draft deposition' do
    deposition = OpenStruct.new(id: '10', title: 'Test', bucket_url: 'burl', draft?: true)
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('http://zenodo.org', api_key: 'KEY').returns(service)
    result = @action.update(@bundle, { deposition_id: '10' })
    assert result.success?
    assert_equal '10', @bundle.metadata[:deposition_id]
    assert_nil @bundle.metadata[:record_id]
    assert_equal 'Test', @bundle.metadata[:title]
  end

  test 'update stores record information for published deposition' do
    deposition = OpenStruct.new(id: '10', record_id: '99', title: 'Pub', bucket_url: 'burl', draft?: false)
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('http://zenodo.org', api_key: 'KEY').returns(service)
    result = @action.update(@bundle, { deposition_id: '10' })
    assert result.success?
    assert_equal '99', @bundle.metadata[:record_id]
    assert_nil @bundle.metadata[:deposition_id]
  end
  test 'update adds repo history for draft deposition' do
    bundle = FakeUploadBundle.new(id: '1', metadata: { zenodo_url: 'http://zenodo.org', auth_key: 'KEY' })
    service = mock('service')
    deposition = OpenStruct.new(id: '10', record_id: '20', title: 'Draft', bucket_url: 'b', draft?: true, version: 'draft')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('http://zenodo.org', api_key: 'KEY').returns(service)

    ::Configuration.repo_history.expects(:add_repo).with(
      regexp_matches(%r{zenodo\.org}),
      ConnectorType::ZENODO,
      title: 'Draft',
      note: 'draft'
    )

    action = Zenodo::Handlers::DatasetSelect.new
    result = action.update(bundle, { deposition_id: '10' })

    assert result.success?
    assert_equal deposition, result.resource
  end

  test 'update adds repo history for published deposition' do
    bundle = FakeUploadBundle.new(id: '1', metadata: { zenodo_url: 'http://zenodo.org', auth_key: 'KEY' })
    service = mock('service')
    deposition = OpenStruct.new(id: '10', record_id: '20', title: 'Pub', bucket_url: 'b', draft?: false, version: 'published')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('http://zenodo.org', api_key: 'KEY').returns(service)

    ::Configuration.repo_history.expects(:add_repo).with(
      regexp_matches(%r{zenodo\.org}),
      ConnectorType::ZENODO,
      title: 'Pub',
      note: 'published'
    )

    action = Zenodo::Handlers::DatasetSelect.new
    result = action.update(bundle, { deposition_id: '10' })

    assert result.success?
    assert_equal deposition, result.resource
  end
end
