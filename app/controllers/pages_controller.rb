class PagesController < ApplicationController
  def home; end
  def terms; end
  def privacy; end

  def landing
    render layout: "landing"
  end
end
