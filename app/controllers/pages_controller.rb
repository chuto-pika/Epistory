class PagesController < ApplicationController
  def home; end
  def terms; end
  def privacy; end

  def landing
    redirect_to root_path, status: :moved_permanently
  end
end
