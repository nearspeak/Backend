##
# The overview controller.
class OverviewController < ApplicationController
  before_action :authenticate_customer!

  ##
  # Show the overview (dashboard) view.
  def index
    if current_customer.role == 'admin'
      @tags = Tag.all
      @places = Place.all
      @top10_tags = Tag.top_10_scanned
    else
      @tags = Tag.my(current_customer)
      @places = Place.my(current_customer)
      @top10_tags = Tag.my_top_10_scanned(current_customer)
    end
  end
end
