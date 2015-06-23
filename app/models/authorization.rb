##
# The Authorizaton model handels the authentication for the customer model.
class Authorization < ActiveRecord::Base
  belongs_to :customer

  after_create :fetch_details

  ##
  # Fetch customer details from a authentication provider.
  def fetch_details
    self.send("fetch_details_from_#{self.provider.downcase}")
  end

  ##
  # Fetch customer details from facebook.
  def fetch_details_from_facebook
    graph = Koala::Facebook::API.new(self.token)
    facebook_data = graph.get_object("me")
    self.username = facebook_data['username']
    self.save
  end

  ##
  # Fetch customer details from devise
  def fetch_details_from_devise
    self.username = 'devise_user'
    self.save
  end
end
