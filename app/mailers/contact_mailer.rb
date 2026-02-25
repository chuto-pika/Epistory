class ContactMailer < ApplicationMailer
  def notify_admin(contact)
    @contact = contact
    mail(
      to: ENV.fetch("CONTACT_EMAIL", "admin@example.com"),
      subject: "【Epistory】お問い合わせがありました"
    )
  end
end
