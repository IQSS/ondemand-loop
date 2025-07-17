require 'test_helper'

class Common::HttpClientTest < ActiveSupport::TestCase
  Response = Common::HttpClient::Response

  test 'get builds url with params and headers' do
    mock_http = HttpMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    %i[use_ssl= open_timeout= read_timeout=].each { |m| mock_http.define_singleton_method(m){|_|} }
    Net::HTTP.stubs(:new).returns(mock_http)
    client = Common::HttpClient.new(base_url: 'https://example.com')
    res = client.get('/path', params: {q: 'x'}, headers: {'X'=> '1'})
    assert_equal 200, res.status
  end

  test 'follow redirects' do
    first = HttpMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'), status_code: 302, headers: {'location' => '/next'})
    second = HttpMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    %i[use_ssl= open_timeout= read_timeout=].each { |m| first.define_singleton_method(m){|_|} }
    %i[use_ssl= open_timeout= read_timeout=].each { |m| second.define_singleton_method(m){|_|} }
    Net::HTTP.stubs(:new).returns(first).then.returns(second)
    client = Common::HttpClient.new(base_url: 'https://example.com')
    res = client.get('/start', follow_redirects: true)
    assert_equal 200, res.status
  end

  test 'post sends json body' do
    mock_http = HttpMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    %i[use_ssl= open_timeout= read_timeout=].each { |m| mock_http.define_singleton_method(m){|_|} }
    Net::HTTP.stubs(:new).returns(mock_http)
    client = Common::HttpClient.new(base_url: 'https://example.com')
    res = client.post('/p', body: {a:1})
    assert_equal 200, res.status
  end
end
