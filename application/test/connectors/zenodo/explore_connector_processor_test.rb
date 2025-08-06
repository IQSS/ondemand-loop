require 'test_helper'

class Zenodo::ExploreConnectorProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Zenodo::ExploreConnectorProcessor.new
  end

  test 'show delegates to explorer with object id' do
    params = { connector_type: ConnectorType::ZENODO, object_type: :records, object_id: '3', repo_url: :url }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::ZENODO, :records, '3').returns(explorer)
    explorer.expects(:show).with(params).returns(:found)
    assert_equal :found, @processor.show(params)
  end

  test 'create delegates to explorer with object id' do
    params = { connector_type: ConnectorType::ZENODO, object_type: :records, object_id: '2', project_id: '3', file_ids: ['f1'] }
    explorer = mock('explorer')
    ConnectorActionDispatcher.expects(:explorer).with(ConnectorType::ZENODO, :records, '2').returns(explorer)
    explorer.expects(:create).with(params).returns(:created)
    assert_equal :created, @processor.create(params)
  end

  test 'landing returns not supported result' do
    result = @processor.landing(connector_type: ConnectorType::ZENODO)
    assert_not result.success?
    assert_equal I18n.t('connectors.zenodo.actions.landing.message_action_not_supported'), result.message[:alert]
  end
end
