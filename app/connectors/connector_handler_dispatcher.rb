# frozen_string_literal: true

class ConnectorHandlerDispatcher
  # Dynamically loads a connector handler class based on the connector type and
  # object type. All handlers are initialized with an object_id which may be nil.
  def self.handler(connector_type, object_type, object_id = nil)
    module_name = connector_type.to_s.camelize
    class_name = object_type.to_s.camelize
    connector_class = "#{module_name}::Handlers::#{class_name}"

    connector_class.constantize.new(object_id)
  rescue NameError
    raise ConnectorNotSupported, "Invalid connector handler #{connector_class}"
  end

  class ConnectorNotSupported < StandardError; end
end

