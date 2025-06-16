# frozen_string_literal: true

module Command
  class Response
    attr_reader :status, :headers, :body

    def initialize(status: 200, headers: {}, body: {})
      @status = status
      @headers = headers || {}
      @body = OpenStruct.new(body)
    end

    def to_h
      {
        status: status,
        headers: headers,
        body: body.to_h
      }
    end

    def to_json
      to_h.to_json
    end

    def self.from_json(json)
      data = JSON.parse(json, symbolize_names: true)
      new(
        status: data[:status],
        headers: data[:headers] || {},
        body: data[:body] || {}
      )
    end

    def self.error(status: 500, message:, handler: nil)
      new(
        status: status,
        headers: { handler: handler&.class&.name },
        body: { message: message }
      )
    end

    def self.ok(body:, handler: nil)
      new(
        status: 200,
        headers: { handler: handler&.class&.name },
        body: body
      )
    end
  end
end
