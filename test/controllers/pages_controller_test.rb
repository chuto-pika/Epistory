require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "top page includes OGP meta tags" do
    get root_path

    assert_response :success
    assert_select 'meta[property="og:title"]', true
    assert_select 'meta[property="og:description"]', true
    assert_select 'meta[property="og:type"][content="website"]', true
    assert_select 'meta[property="og:url"]', true
    assert_select 'meta[property="og:image"]', true
    assert_select 'meta[property="og:site_name"][content="Epistory"]', true
  end

  test "top page includes Twitter Card meta tags" do
    get root_path

    assert_response :success
    assert_select 'meta[name="twitter:card"][content="summary_large_image"]', true
    assert_select 'meta[name="twitter:title"]', true
    assert_select 'meta[name="twitter:description"]', true
    assert_select 'meta[name="twitter:image"]', true
  end

  test "top page includes meta description" do
    get root_path

    assert_response :success
    assert_select 'meta[name="description"]', true
  end
end
