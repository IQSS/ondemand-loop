# frozen_string_literal: true

require 'test_helper'

class Dataverse::DataverseInstallationServiceTest < ActiveSupport::TestCase
  test 'delegates to DataverseHub for http(s) URLs' do
    client = mock('http_client')
    provider = mock('hub_provider')
    provider.expects(:installations).returns([:hub])

    Dataverse::DataverseHub.expects(:new).with(
      url: 'https://hub.example/api/installations',
      http_client: client,
      expires_in: 5.minutes
    ).once.returns(provider)

    service = Dataverse::DataverseInstallationService.new(
      url: 'https://hub.example/api/installations',
      http_client: client,
      expires_in: 5.minutes
    )

    assert_equal [:hub], service.installations
  end

  test 'delegates to DataverseInstallationFile for file URLs' do
    provider = mock('file_provider')
    provider.expects(:installations).returns([:file])

    Dataverse::DataverseInstallationFile.expects(:new).with(
      path: '/tmp/dataverse.json',
      expires_in: 2.minutes
    ).once.returns(provider)

    service = Dataverse::DataverseInstallationService.new(
      url: 'file:///tmp/dataverse.json',
      expires_in: 2.minutes
    )

    assert_equal [:file], service.installations
  end

  test 'raises error for unsupported schemes' do
    service = Dataverse::DataverseInstallationService.new(url: 'ftp://example.com/installations')

    assert_raises ArgumentError do
      service.installations
    end
  end
end
