##
# The Place model can combine multiple nearspeak tags into one location.
class Place < ActiveRecord::Base
  validates :latitude, presence: true
  validates :longitude, presence: true
  
  belongs_to :customer
  has_many :tags
  
  scope :my, ->(current_customer) { where("customer_id = ?", current_customer).order(id: :desc) }
end
