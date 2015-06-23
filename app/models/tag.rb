##
# The Tag model.
class Tag < ActiveRecord::Base
  validates :tag_identifier, uniqueness: true
  
  # time based validations
  validate :start_must_be_before_end_time
  validate :validate_start_and_stop_time
  
  # date based validations
  validate :validate_start_and_stop_date
  validate :start_must_be_before_end_date
  
  # add a random tag identifier
  before_validation :create_random_tag_identifier

  belongs_to :place
  belongs_to :customer
  has_one :text_record, dependent: :destroy
  has_many :hardwares, dependent: :destroy

  has_one :original_name, class_name: 'NameTranslation', foreign_key: 'original_name_id', dependent: :destroy
  has_many :name_translations, dependent: :destroy

  has_ancestry orphan_strategy: :rootify

  accepts_nested_attributes_for :text_record
  accepts_nested_attributes_for :original_name
  accepts_nested_attributes_for :name_translations

  # set the default sort order
  #default_scope { order('Tags.id DESC') }
  
  scope :my, ->(current_customer) { where("customer_id = ?", current_customer).order(id: :desc) }
  scope :active, -> { where(active: true) }
  scope :with_tag_identifier, ->(tag_identifier) { where("tag_identifier = ?", tag_identifier)}
  scope :top_10_scanned, -> { where("scan_count > 0").order(scan_count: :desc).limit(10) }
  scope :my_top_10_scanned, ->(current_customer) { where("scan_count > 0 AND customer_id = ?", current_customer).order(scan_count: :desc).limit(10) }

  ##
  # Show a display name.
  # 1. if available show original text
  # 2. if available show old name
  # 3. show tag id
  def display_name
    if original_name.nil?
      id
    else
      original_name.text.nil? ? id: original_name.text
    end
  end
  
  ##
  # Create a new tag with the given data.
  #
  # @param text [String] The translation text.
  # @param lang_code [String] The language code.
  # @param purchase_id [String] The purchase id.
  # @param gender [String] The gender for the translation.
  # @param hardware_id [String] The hardware id.
  # @param hardware_type [String] The hardware type.
  # @param ble_major [String] The bluetooth le major id.
  # @param ble_minor [String] The bluetooth le minor id.
  # @param name [String] The name of the tag.
  # @param parent_id [String] The parent if of the tag.
  # @param latitude [String] The latitude of the hardware.
  # @param longitude [String] The longitude of the hardware.
  # @param customer [String] The customer of the tag.
  def self.create_with_data(text, lang_code, purchase_id, gender, hardware_id, hardware_type, ble_major, ble_minor, name, parent_id, latitude, longitude, customer)
    #logger.info 'DBG: create new tag with text: ' + text + ' and lang: ' + lang_code + ' and purchase id: ' + purchase_id + 'and hardware id: ' + hardware_id

    # check if the language code exists
    unless TranslationsHelper.is_valid_language lang_code
      return 400, nil, 'Translation language is not supported', 'TranslationError'
    end

    # check if enough purchases are available for the given id
    purchase_count = Purchase.check_purchases(purchase_id)

    hardware = nil
    unless hardware_id.nil?
      if HardwaresHelper.validate_hardware_type(hardware_type)

        old_hardware = nil
        #remove hardware from other tags first
        if hardware_type == HardwaresHelper::TYPE_BLE
          unless ble_major.nil? and ble_minor.nil?
            old_hardware = Hardware.where('identifier = ? AND hardware_type = ? AND major = ? AND minor = ?', hardware_id, hardware_type, ble_major, ble_minor)
          end
        else
          old_hardware = Hardware.where('identifier = ? AND hardware_type = ?', hardware_id, hardware_type)
        end

        unless old_hardware.nil?
          old_hardware.destroy_all
        end

        hardware = Hardware.create(identifier: hardware_id, hardware_type: hardware_type)

        unless hardware.nil?
          # add major and minor id on bluetooth beacons
          if hardware_type == HardwaresHelper::TYPE_BLE
            unless ble_major.nil? and ble_minor.nil?
              hardware.major = ble_major
              hardware.minor = ble_minor
            end
          end

          # add hardware location
          unless latitude.nil? and longitude.nil?
            location = HardwareLocation.create(latitude: latitude, longitude: longitude)

            unless location.nil?
              hardware.hardware_locations << location
            end
          end
        end
      end
    end

    # check if gender value is f or m. If not set default: m
    unless gender == 'm' or gender == 'f'
      gender = 'm'
    end

    if purchase_count < MAX_TAGS_PER_PURCHASE_ID

      tag = Tag.create(
      customer: customer,
      text_record_attributes:
      {
        original_text_attributes: { :text => text, :lang_code => lang_code },
        gender: gender,
        purchase_attributes: { :purchase_id => purchase_id }
      }
      )

      if tag.nil? or tag.id.nil?
        return 400, nil, 'Error while creating now tag', 'CreationError'
      else
        # if there is already some hardware info save it to the current tag
        unless hardware.nil?
          tag.hardwares << hardware
          tag.save
        end

        # if there is a name add it as original name to the current tag
        unless name.nil?
          original_text = NameTranslation.create(:text => name, :lang_code => lang_code)
          tag.original_name = original_text
          tag.save
        end

        if parent_id.nil?
          tag.parent_id = parent_id
        end

        return 200, tag, '', ''
      end
    else
      return 400, nil, 'You are out of purchases', 'OutOfPurchases'
    end
  end

  ##
  # Add a hardware to a tag.
  #
  # @param hardware_id [String] The hardware id.
  # @param hardware_type [String] The hardware type.
  # @param ble_major [String] The bluetooth le major id.
  # @param ble_minor [String] The bluetooth le minor id.
  # @param latitude [String] The latitude of the hardware location.
  # @param longitude [String] The longitude of the hardware location.
  def add_hardware_id_to_tag(hardware_id, hardware_type, ble_major, ble_minor, latitude, longitude)
    if hardware_id.nil?
      return :status => 400, :json => { :error => { :message => 'Error hardware id is missing', :code => 'UpdatedError' }}
    else
      if HardwaresHelper.validate_hardware_type(hardware_type)

        old_hardware = nil
        #remove hardware from other tags first
        if hardware_type == HardwaresHelper::TYPE_BLE
          unless ble_major.nil? and ble_minor.nil?
            old_hardware = Hardware.where('identifier = ? AND hardware_type = ? AND major = ? AND minor = ?', hardware_id, hardware_type, ble_major, ble_minor)
          end
        else
          old_hardware = Hardware.where('identifier = ? AND hardware_type = ?', hardware_id, hardware_type)
        end

        unless old_hardware.nil?
          old_hardware.destroy_all
        end

        hardware = Hardware.create(identifier: hardware_id, hardware_type: hardware_type)

        unless hardware.nil?

          # add major and minor id on bluetooth beacons
          if hardware_type == HardwaresHelper::TYPE_BLE
            unless ble_major.nil? and ble_minor.nil?
              hardware.major = ble_major
              hardware.minor = ble_minor
            end
          end

          # add hardware location
          unless latitude.nil? and longitude.nil?
            location = HardwareLocation.create(latitude: latitude, longitude: longitude)

            unless location.nil?
              hardware.hardware_locations << location
            end
          end
        end

        self.hardwares << hardware
        self.save
      else
        return 400, nil, 'Error while adding hardware', 'AddingHardwareError'
      end

      return 200, self, '', ''
    end
  end

  ##
  # Set the original text for the tag.
  #
  # @param text [String] The original text.
  # @param lang_code [String] The language code of the original text.
  def set_original_text(text, lang_code)
    text_record.set_original_text(text, lang_code)
  end

  ##
  # Show all tags by hardware id and hardware type.
  #
  # @param hardware_id [String] The hardware id.
  # @param hardware_type [String] The hardware type.
  def self.show_by_hardware_id(hardware_id, hardware_type)
    unless hardware_id.nil? and hardware_type.nil?
      Tag.joins(:hardwares).find_by('hardwares.identifier' => hardware_id,
      'hardwares.hardware_type' => hardware_type,
      active: true)
    end
  end

  ##
  # Show all tags by bluetooth le hardware id.
  #
  # @param hardware_id [String] The hardware id.
  # @param hardware_type [String] The hardware type.
  # @param major [String] The major id.
  # @param minor [String] The minor id.
  def self.show_by_ble_hardware_id(hardware_id, hardware_type, major, minor)
    unless hardware_id.nil? and hardware_type.nil? and major.nil? and minor.nil?
      Tag.joins(:hardwares).find_by('hardwares.identifier' => hardware_id,
      'hardwares.hardware_type' => hardware_type,
      'hardwares.major' => major,
      'hardwares.minor' => minor,
      active: true)
    end
  end

  ##
  # Add a location to a hardware.
  #
  # @param hardware_id [String] The hardware id.
  # @param latitude [String] The latitude of the hardware.
  # @param longitude [String] The longitude of the hardware.
  def add_location_to_hardware(hardware_id, latitude, longitude)
    unless hardware_id.nil? and latitude.nil? and longitude.nil?
      tag = Tag.joins(:hardwares).find_by('hardwares.identifier' => hardware_id)

      location = HardwareLocation.create(latitude: latitude, longitude: longitude)

      tag.hardwares.each do |item|
        if item.identifier == hardware_id
          item.hardware_locations << location
        end
      end
    end
  end

  ##
  # Returns the translated name, or the original text if the language is the current.
  #
  # @param lang_code [String] The language code.
  def get_name_translation(lang_code)
    #format language code to a valid bing translate format
    lang_code_cut = TranslationsHelper.cut_country(lang_code)
    if lang_code_cut.nil?
      return nil
    end

    # check if this is a valid language code
    unless TranslationsHelper.is_valid_language(lang_code_cut)
      return nil
    end

    # check if original text is in the new language
    unless original_name.nil?
      lang_code_original_cut = TranslationsHelper.cut_country(original_name.lang_code)

      if original_name.lang_code == lang_code
        return original_name.text
      elsif original_name.lang_code == lang_code_cut
        add_name_translation(original_name.text, lang_code)
        return original_name.text
      elsif lang_code_original_cut == lang_code_cut
        add_name_translation(original_name.text, lang_code)
        return original_name.text
      end
    end

    # check if translation is already available, if not translate it via bing
    trans = name_translations.find_by_lang_code(lang_code)
    if trans.nil?
      trans_cut = name_translations.find_by_lang_code(lang_code_cut)

      # check if there is a translation only with the language code, without country code
      if trans_cut.nil?
        return translate_name_into_lang_code(lang_code)
      else
        add_name_translation(trans_cut.text, lang_code)
        return trans_cut.text
      end
    else
      trans.text
    end
  end
  
  ##
  # Returns true if the tag is currently active, else it returns false.
  def currently_active
    # check if tag is active
    if self.active == false
      return false
    end
    
    # check if time based activation is active
    if self.active_time
      unless current_time_active
        return false
      end
    end
    
    # check if date based activation is action
    if self.active_date
      unless current_date_active
        return false
      end
    end
    
    return true
  end
  
  ##
  # Returns true if the active_time is currently active, else it returns false.
  def current_time_active
    if self.active_start_time.nil?  or self.active_stop_time.nil?
      return false
    end
    
    # get the current time
    current_time = Time.now.utc
    
    # check if current time is in range
    if self.active_start_time.utc.strftime( "%H%M%S%N" ) <= current_time.utc.strftime( "%H%M%S%N" ) and self.active_stop_time.utc.strftime( "%H%M%S%N" ) >= current_time.utc.strftime( "%H%M%S%N" )
      return true
    else
      return false
    end
    
    return false
  end
  
  ##
  # Checks if the current tag is active.
  def current_date_active
    if self.active_start_date.nil? or self.active_stop_date.nil?
      return false
    end
    
    # get the current time
    current_time = Time.now
    
    if self.active_start_date <= current_time and self.active_stop_date >= current_time
      return true
    else
      return false
    end
    
    return false
  end
  
  ##
  # Returns the active time as a string.
  def active_time_to_string
    unless self.active_start_time.nil? and self.active_stop_time.nil?
      timeFormat = "%H:%M"
      return self.active_start_time.utc.strftime(timeFormat) + " - " + self.active_stop_time.utc.strftime(timeFormat)
    end
    
    return ""
  end
  
  ##
  # Returns the active date as a string. 
  def active_date_to_string
    unless self.active_start_date.nil? and self.active_stop_date.nil?
      dateFormat = "%d.%m.%Y"
      
      return self.active_start_date.strftime(dateFormat) + " - " + self.active_stop_date.strftime(dateFormat)
    end
    
    return ""
  end
  
  ##
  # Returns the top 10 scanned tags.
  #
  # @param current_customer [String] The current customer.
  def self.my_top10_chart_data(current_customer)
    Tag.my_top_10_scanned(current_customer).map { |tag| [tag.display_name, tag.scan_count] }
  end

  ### PRIVATE ###
  private

  ##
  # Use bing translate to add new name_translations for the name.
  #
  # @param lang_code [String] The language code.
  def translate_name_into_lang_code(lang_code)
    unless lang_code.nil? and original_name.nil?
      original_name_translation_code = TranslationsHelper.cut_country(original_name.lang_code)
      to_name_translation_code = TranslationsHelper.cut_country(lang_code)

      translator = BingTranslator.new(BING_CLIENT_ID_DEV, BING_CLIENT_SECRET_DEV)

      text = translator.translate(original_name.text, :from => original_name_translation_code, :to => to_name_translation_code)
      add_name_translation(text, lang_code)

      text
    end
  end

  ##
  # Add new name translation into the system.
  #
  # @param text [String] The new name translation text.
  # @param lang_code [String] The language code.
  def add_name_translation(text, lang_code)
    name_translation = NameTranslation.create(:text => text, :lang_code => lang_code)

    name_translations << name_translation
  end
  
  ##
  # Check if start time is before stop time.
  def start_must_be_before_end_time
    unless active_start_time.nil? or active_stop_time.nil?
      errors.add(:active_start_time, "must be before stop time") unless
          active_start_time < active_stop_time
    end
  end
  
  ##
  # If active time is enabled start and stop time needs to be set.
  def validate_start_and_stop_time
    if active_time
      if active_start_time.nil? or active_stop_time.nil?
        errors.add(:active_time, "start time or end time not set")
      end
    end
  end
  
  ##
  # Check if start date is before stop date.
  def start_must_be_before_end_date
    unless active_start_date.nil? or active_stop_date.nil?
      errors.add(:active_date, "Start date must be before stop date") unless
        active_start_date < active_stop_date
    end
  end
  
  ##
  # If active date is enabled start and stop date needs to be set.
  def validate_start_and_stop_date
    if active_date
      if active_start_date.nil? or active_stop_date.nil?
        errors.add(:active_date, "start date or end date not set")
      end
    end
  end
  
  ##
  # Create a random tag identifier.
  def create_random_tag_identifier
    if self.tag_identifier.nil?
      self.tag_identifier = SecureRandom.hex(6) # Generate a 12 character long random number
    end
  end
end
