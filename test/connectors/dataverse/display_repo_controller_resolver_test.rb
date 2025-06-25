require 'test_helper'

class Dataverse::DisplayRepoControllerResolverTest < ActionDispatch::IntegrationTest
  def setup
    @resolver = Dataverse::DisplayRepoControllerResolver.new
    helper = Class.new do
      def view_dataverse_path(host, id, **opts); "/dv/#{host}/#{id}"; end
      def view_dataverse_dataset_path(dv_hostname:, persistent_id:, **opts); "/dv/#{dv_hostname}/datasets/#{persistent_id}"; end
    end.new
    @resolver.instance_variable_set(:@url_helper, helper)
  end

  test 'dataverse root url returns path' do
    url = 'https://demo.dataverse.org'
    result = @resolver.get_controller_url(url)
    assert_equal '/dv/demo.dataverse.org/:root', result.redirect_url
    assert result.success?
  end

  test 'dataset url returns dataset path' do
    url = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/DS'
    result = @resolver.get_controller_url(url)
    assert_equal '/dv/demo.dataverse.org/datasets/doi:10.1234/DS', result.redirect_url
  end

  test 'collection url returns collection path' do
    url = 'https://demo.dataverse.org/dataverse/COL1'
    result = @resolver.get_controller_url(url)
    assert_equal '/dv/demo.dataverse.org/COL1', result.redirect_url
  end
end
