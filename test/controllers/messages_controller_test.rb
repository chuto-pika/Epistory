require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  # === new ===
  test "new initializes session and redirects to step1" do
    get new_message_path

    assert_redirected_to step1_message_path
  end

  # === step1 ===
  test "step1 displays recipients" do
    get step1_message_path

    assert_response :success
    assert_select "input[name='recipient_id']", minimum: 1
  end

  test "save_step1 saves recipient_id and redirects to step2" do
    recipient = recipients(:parent)
    post step1_message_path, params: { recipient_id: recipient.id }

    assert_redirected_to step2_message_path
  end

  test "save_step1 redirects back when no recipient selected" do
    post step1_message_path, params: { recipient_id: "" }

    assert_redirected_to step1_message_path
  end

  # === step2 ===
  test "step2 redirects to step1 when recipient not selected" do
    get step2_message_path

    assert_redirected_to step1_message_path
  end

  test "step2 displays occasions when step1 completed" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    get step2_message_path

    assert_response :success
    assert_select "input[name='occasion_id']", minimum: 1
  end

  test "save_step2 saves occasion_id and redirects to step3" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }

    assert_redirected_to step3_message_path
  end

  test "save_step2 redirects back when no occasion selected" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: "" }

    assert_redirected_to step2_message_path
  end

  # === step3 ===
  test "step3 redirects to step1 when previous steps not completed" do
    get step3_message_path

    assert_redirected_to step1_message_path
  end

  test "step3 displays impressions when step1 and step2 completed" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }
    get step3_message_path

    assert_response :success
    assert_select "input[name='impression_ids[]']", minimum: 1
  end

  test "save_step3 saves impression_ids and redirects to root" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }
    post step3_message_path, params: { impression_ids: [impressions(:supportive).id, impressions(:reassuring).id] }

    assert_redirected_to root_path
  end

  test "save_step3 redirects back when no impression selected" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }
    post step3_message_path, params: {}

    assert_redirected_to step3_message_path
  end

  # === back button preserves session ===
  test "going back to step1 preserves selected recipient" do
    recipient = recipients(:parent)
    post step1_message_path, params: { recipient_id: recipient.id }
    get step1_message_path

    assert_response :success
    assert_select "input[name='recipient_id'][value='#{recipient.id}'][checked]"
  end

  test "going back to step2 preserves selected occasion" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    occasion = occasions(:birthday)
    post step2_message_path, params: { occasion_id: occasion.id }
    get step2_message_path

    assert_response :success
    assert_select "input[name='occasion_id'][value='#{occasion.id}'][checked]"
  end
end
