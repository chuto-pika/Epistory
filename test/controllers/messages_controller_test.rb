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

  test "save_step3 saves impression_ids and redirects to step4" do
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }
    post step3_message_path, params: { impression_ids: [impressions(:supportive).id, impressions(:reassuring).id] }

    assert_redirected_to step4_message_path
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

  # === step4 ===
  test "step4 redirects to step1 when previous steps not completed" do
    get step4_message_path

    assert_redirected_to step1_message_path
  end

  test "step4 displays episode form when steps 1-3 completed" do
    complete_steps_one_to_three
    get step4_message_path

    assert_response :success
    assert_select "textarea[name='episode']"
  end

  test "save_step4 saves episode and redirects to step5" do
    complete_steps_one_to_three
    post step4_message_path, params: { episode: "先月助けてもらった" }

    assert_redirected_to step5_message_path
  end

  test "save_step4 allows empty episode" do
    complete_steps_one_to_three
    post step4_message_path, params: { episode: "" }

    assert_redirected_to step5_message_path
  end

  test "save_step4 rejects episode exceeding max length" do
    complete_steps_one_to_three
    post step4_message_path, params: { episode: "あ" * (Message::EPISODE_MAX_LENGTH + 1) }

    assert_response :unprocessable_entity
    assert_select "textarea[name='episode']"
  end

  # === step5 ===
  test "step5 redirects to step1 when previous steps not completed" do
    get step5_message_path

    assert_redirected_to step1_message_path
  end

  test "step5 displays feelings when steps 1-3 completed" do
    complete_steps_one_to_three
    get step5_message_path

    assert_response :success
    assert_select "input[name='feeling_id']", minimum: 1
  end

  test "save_step5 saves feeling_id and redirects to step6" do
    complete_steps_one_to_three
    post step5_message_path, params: { feeling_id: feelings(:thanks).id }

    assert_redirected_to step6_message_path
  end

  test "save_step5 redirects back when no feeling selected" do
    complete_steps_one_to_three
    post step5_message_path, params: { feeling_id: "" }

    assert_redirected_to step5_message_path
  end

  # === step6 ===
  test "step6 redirects to step1 when previous steps not completed" do
    get step6_message_path

    assert_redirected_to step1_message_path
  end

  test "step6 displays additional message form when steps 1-5 completed" do
    complete_steps_one_to_five
    get step6_message_path

    assert_response :success
    assert_select "textarea[name='additional_message']"
  end

  test "save_step6 creates message and redirects to show" do
    complete_steps_one_to_five

    assert_difference "Message.count", 1 do
      post step6_message_path, params: { additional_message: "また会おうね" }
    end

    message = Message.last

    assert_redirected_to message_path(message)
    assert_predicate message.generated_content, :present?
  end

  test "save_step6 allows empty additional message" do
    complete_steps_one_to_five

    assert_difference "Message.count", 1 do
      post step6_message_path, params: { additional_message: "" }
    end

    message = Message.last

    assert_redirected_to message_path(message)
  end

  test "save_step6 rejects additional_message exceeding max length" do
    complete_steps_one_to_five

    assert_no_difference "Message.count" do
      post step6_message_path, params: { additional_message: "あ" * (Message::ADDITIONAL_MESSAGE_MAX_LENGTH + 1) }
    end

    assert_response :unprocessable_entity
    assert_select "textarea[name='additional_message']"
  end

  # === show ===
  test "show displays the generated message" do
    complete_steps_one_to_five
    post step6_message_path, params: { additional_message: "" }
    message = Message.last

    get message_path(message)

    assert_response :success
  end

  # === edit ===
  test "edit displays edit form" do
    message = create_message_via_steps

    get edit_message_path(message)

    assert_response :success
    assert_select "textarea"
  end

  # === update ===
  test "update saves edited_content and redirects to show" do
    message = create_message_via_steps

    patch message_path(message), params: { message: { edited_content: "編集済みメッセージ" } }

    assert_redirected_to message_path(message)
    assert_equal "編集済みメッセージ", message.reload.edited_content
  end

  # === restore ===
  test "restore clears edited_content and redirects to edit" do
    message = create_message_via_steps
    message.update(edited_content: "編集済み")

    patch restore_message_path(message)

    assert_redirected_to edit_message_path(message)
    assert_nil message.reload.edited_content
  end

  private

  def complete_steps_one_to_three
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }
    post step3_message_path, params: { impression_ids: [impressions(:supportive).id] }
  end

  def complete_steps_one_to_five
    complete_steps_one_to_three
    post step4_message_path, params: { episode: "テストエピソード" }
    post step5_message_path, params: { feeling_id: feelings(:thanks).id }
  end

  def create_message_via_steps
    complete_steps_one_to_five
    post step6_message_path, params: { additional_message: "" }
    Message.last
  end
end
