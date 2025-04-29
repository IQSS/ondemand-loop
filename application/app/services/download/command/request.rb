# frozen_string_literal: true

module Download::Command
  class Request
    attr_reader :command, :headers, :body

    def initialize(command:, headers: {}, body: {})
      @command = command.to_s
      @headers = headers || {}
      @body = OpenStruct.new(body)
    end

    def to_json
      {
        command: command,
        headers: headers,
        body: body.to_h
      }.to_json
    end

    def self.from_json(json)
      data = JSON.parse(json, symbolize_names: true)
      new(
        command: data[:command],
        headers: data[:headers],
        body: data[:body]
      )
    end
  end
end
