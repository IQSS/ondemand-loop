require 'test_helper'

class Zenodo::Handlers::LandingTest < ActiveSupport::TestCase
  def setup
    @explorer = Zenodo::Handlers::Landing.new
    @repo_url = OpenStruct.new(server_url: 'https://zenodo.org')
  end

  test 'params schema includes expected keys' do
    assert_includes @explorer.params_schema, :query
    assert_includes @explorer.params_schema, :page
    assert_includes @explorer.params_schema, :repo_url
  end

  test 'show runs search when query present' do
    service = mock('search')
    results = OpenStruct.new(items: [])
    service.expects(:search).with('q', page: 2).returns(results)
    Zenodo::SearchService.expects(:new).with('https://zenodo.org').returns(service)
    res = @explorer.show(query: 'q', page: 2, repo_url: @repo_url)
    assert res.success?
    assert_equal results, res.locals[:results]
  end

  test 'show without query skips search' do
    res = @explorer.show(query: nil, repo_url: @repo_url)
    assert res.success?
    assert_nil res.locals[:results]
  end
end
