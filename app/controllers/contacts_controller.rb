class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      ContactMailer.notify_admin(@contact).deliver_later
      redirect_to contact_complete_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def complete; end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end
end
