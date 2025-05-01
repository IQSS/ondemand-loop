require "test_helper"

class DoiSearchControllerTest < ActionDispatch::IntegrationTest
  def setup
    @doi = "10.1234/example.doi"
    @invalid_doi = "invalid-doi"
    @dataverse_url = "https://dataverse.example.org/dataset.xhtml?persistentId=#{@doi}"

    @resolver_result = {
      type: "dataverse",
      object_url: @dataverse_url
    }
  end

  test "should redirect with error if DOI is blank" do
    post doi_search_url, params: { doi: "" }

    assert_redirected_to doi_search_path
    follow_redirect!
    assert_match "Provide a valid DOI", flash[:alert]
  end

  test "should redirect with error if DOI resolution fails" do
    Doi::DoiService.any_instance.stubs(:resolve).with(@invalid_doi).returns(nil)

    post doi_search_url, params: { doi: @invalid_doi }

    assert_redirected_to doi_search_path
    follow_redirect!
    assert_match "Invalid DOI: #{@invalid_doi}", flash[:alert]
  end

  test "should redirect to dataverse viewer if type is dataverse" do
    Doi::DoiService.any_instance.stubs(:resolve).with(@doi).returns(@dataverse_url)
    DoiResolversRegistry.stubs(:resolvers).returns([])
    Doi::DoiResolverService.any_instance.stubs(:resolve).with(@doi, @dataverse_url).returns(@resolver_result)

    post doi_search_url, params: { doi: @doi }

    expected_hostname = URI.parse(@dataverse_url).hostname
    assert_redirected_to view_dataverse_dataset_path(dv_hostname: expected_hostname, persistent_id: @doi)
  end

  test "should redirect with error if DOI type is unsupported" do
    unsupported_result = { type: "unknown", object_url: "http://example.com/other" }

    Doi::DoiService.any_instance.stubs(:resolve).with(@doi).returns("http://example.com/other")
    DoiResolversRegistry.stubs(:resolvers).returns([])
    Doi::DoiResolverService.any_instance.stubs(:resolve).with(@doi, "http://example.com/other").returns(unsupported_result)

    post doi_search_url, params: { doi: @doi }

    assert_redirected_to doi_search_path
    follow_redirect!
    assert_match "DOI not supported: #{@doi} type: unknown", flash[:alert]
  end
end
