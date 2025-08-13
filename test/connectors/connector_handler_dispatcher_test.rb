# frozen_string_literal: true
require 'test_helper'

class ConnectorHandlerDispatcherTest < ActiveSupport::TestCase
  test 'loads connector handler for zenodo connector_edit' do
    handler = ConnectorHandlerDispatcher.handler(ConnectorType::ZENODO, :connector_edit)
    assert_instance_of Zenodo::Handlers::ConnectorEdit, handler
  end

  test 'loads connector handler for zenodo landing' do
    handler = ConnectorHandlerDispatcher.handler(ConnectorType::ZENODO, :landing)
    assert_instance_of Zenodo::Handlers::Landing, handler
  end

  test 'passes object id to handler constructor' do
    module Zenodo::Handlers
      class Dummy
        attr_reader :id

        def initialize(id)
          @id = id
        end
      end
    end

    handler = ConnectorHandlerDispatcher.handler(ConnectorType::ZENODO, :dummy, 456)
    assert_instance_of Zenodo::Handlers::Dummy, handler
    assert_equal 456, handler.id
  ensure
    Zenodo::Handlers.send(:remove_const, :Dummy)
  end

  test 'raises error for unknown handler' do
    assert_raises(ConnectorHandlerDispatcher::ConnectorNotSupported) do
      ConnectorHandlerDispatcher.handler(ConnectorType::ZENODO, :missing)
    end
  end
end
