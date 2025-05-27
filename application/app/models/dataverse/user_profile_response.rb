module Dataverse
  class UserProfileResponse
    attr_reader :status, :id, :identifier, :display_name, :first_name, :last_name, :email, :superuser, :deactivated, :persistent_user_id

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @id = parsed.dig(:data, :id)
      @identifier = parsed.dig(:data, :identifier)
      @display_name = parsed.dig(:data, :displayName)
      @first_name = parsed.dig(:data, :firstName)
      @last_name = parsed.dig(:data, :lastName)
      @email = parsed.dig(:data, :email)
      @superuser = parsed.dig(:data, :superuser)
      @deactivated = parsed.dig(:data, :deactivated)
      @persistent_user_id = parsed.dig(:data, :persistentUserId)
    end
  end
end