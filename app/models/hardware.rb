##
# The Hardware model handles hardware related informations for the nearspeak tag.
class Hardware < ActiveRecord::Base
  validates :identifier, presence: true
  validates :hardware_type, presence: true

  before_validation :format_hardware
  after_validation :validate_hardware

  belongs_to :tag

  has_many :hardware_locations, dependent: :destroy

  scope :with_location, -> { joins(:hardware_locations).where('latitude IS NOT NULL AND longitude IS NOT NULL') }
  scope :all_ble_uuids, -> { select(:identifier).distinct.where("hardware_type = ? AND major IS NOT NULL AND minor IS NOT NULL AND major != '' AND minor != '' AND char_length(identifier) >= 30", HardwaresHelper::TYPE_BLE) }

  ##
  # Output the current location of the tag.
  def current_location
    self.hardware_locations.last
  end

  ##
  # Format the hardware identifier into a valid format.
  def format_hardware
    # format iBeacon hardware
    if hardware_type.eql? HardwaresHelper::TYPE_BLE
      self.identifier = format_uuid(self.identifier)
    end
  end

  ##
  # Validate the hardare
  def validate_hardware
    # check if hardware is already setup in the system
    hw = Hardware.where(:identifier => self.identifier, :major => self.major, :minor => self.minor, :hardware_type => self.hardware_type)

    unless hw.blank?
      return errors.add(:identifier, I18n.t('hardware_validate_exists'))
    end

    # validate iBeacon hardware
    if hardware_type.eql? HardwaresHelper::TYPE_BLE
      validate_ble_hardware
    end
  end

  ##
  # Validate bluetooth le hardware.
  def validate_ble_hardware
    # validate iBeacon hardware
    if hardware_type.eql? HardwaresHelper::TYPE_BLE
      unless is_valid_uuid(self.identifier)
        return errors.add(:identifier, I18n.t('hardware_validate_identifier_invalid'))
      end

      if self.major.blank?
        return errors.add(:major, I18n.t('hardware_validate_major_required'))
      end

      if self.minor.blank?
        return errors.add(:minor, I18n.t('hardware_validate_minor_required'))
      end
    end
  end

  ### PRIVATE ###
  private

  ##
  # Format UUIDs.
  #
  # @param uuid [String] The UUID to format.  
  def format_uuid(uuid)
    uuid.tr('-','').upcase
  end

  ##
  # Check if the given UUID is valid.
  #
  # @param uuid [String] The UUID to check.
  def is_valid_uuid(uuid)
    !uuid[/\H/]
  end
end
