##
# The HardwareLocation model handles locations for the hardware model.
class HardwareLocation < ActiveRecord::Base
  validates :latitude, presence: true
  validates :longitude, presence: true

  belongs_to :hardware
end
