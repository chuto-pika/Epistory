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

  test "landing page redirects to root" do
    get landing_path

    assert_response :moved_permanently
    assert_redirected_to root_path
  end

  test "top page uses application layout with header CTA" do
    get root_path

    assert_select 'header a[href="/message/new"]', text: "メッセージを作る"
  end

  test "top page has CTA links to step1" do
    get root_path

    assert_select 'a[href="/message/step1"]', minimum: 2
  end

  test "top page has four sections" do
    get root_path

    assert_select "section", 4
  end
end
