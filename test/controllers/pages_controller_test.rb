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

  test "landing page returns success" do
    get landing_path

    assert_response :success
  end

  test "landing page uses landing layout with header CTA" do
    get landing_path

    assert_select 'header a[href="/message/step1"]', text: "メッセージを作る"
  end

  test "landing page includes OGP meta tags" do
    get landing_path

    assert_response :success
    assert_select 'meta[property="og:title"]', true
    assert_select 'meta[property="og:description"]', true
    assert_select 'meta[property="og:site_name"][content="Epistory"]', true
  end

  test "landing page has CTA links to step1" do
    get landing_path

    assert_select 'a[href="/message/step1"]', minimum: 2
  end

  test "landing page has four sections" do
    get landing_path

    assert_select "section", 4
  end
end
