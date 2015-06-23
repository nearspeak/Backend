##
# The API tag controller.
class API::V1::TagsController < API::V1::ApiApplicationController
  
  ##
  # Get infos about a specific tag via the nearspeak ID.
  #
  # @return [String] The requested tag as JSON object.
  def show
    tag_identifier = params[:id]
    lang_code = params[:lang]

    tag = Tag.with_tag_identifier(tag_identifier).active.first
    
    unless tag.nil?
      # check if the tag is currently active
      unless tag.currently_active
        tag = nil
      end
    
      tag_scanned(tag)
    end

    return_tag_infos(tag, lang_code)
  end

  ##
  # Get infos about a specific tag via the hardware identifier.
  #
  # @return [String] The requested tag as JSON object.
  def show_by_hardware_id
    hardware_id = params[:id]
    hardware_type = params[:type]

    # optional
    lang_code = params[:lang]
    latitude = params[:lat]
    longitude = params[:lon]
    ble_major = params[:major]
    ble_minor = params[:minor]

    error = []
    if hardware_id.nil?
      error << 'id'
    end

    if hardware_type.nil?
      error << 'type'
    end

    # also require major und minor id by bluetooth beacons
    unless hardware_type.nil?
      if hardware_type == HardwaresHelper::TYPE_BLE
        if ble_major.nil?
          error << 'major'
        end

        if ble_minor.nil?
          error << 'minor'
        end
      end
    end

    if error.length > 0
      return_error_infos(400, 'Request values are missing', 'InvalidRequest', error)
      return
    end

    if hardware_type == HardwaresHelper::TYPE_BLE
      tag = Tag.show_by_ble_hardware_id(hardware_id, hardware_type, ble_major, ble_minor)
    else
      tag = Tag.show_by_hardware_id(hardware_id, hardware_type)
    end

    # add location to hardware
    unless latitude.nil? and longitude.nil? and tag.nil?
      tag.add_location_to_hardware(hardware_id, latitude, longitude)
    end

    # update scan counter
    unless tag.nil?
      tag_scanned(tag)
    end

    return_tag_infos(tag, lang_code)
  end

  ##
  # Show all tags from the current customer.
  #
  # @return [String] The requested tag as JSON object.
  def show_my_tags
    tags = Tag.where('customer_id = ? AND active = ?', current_customer.id, true)

    if tags.nil?
      return_error_infos(400, 'No tags found', 'NoTagsFound', nil)
    else
      json_tags = []

      tags.each { |tag| json_tags << create_tag_infos(tag, nil) }

      render :status => 200, :json => { :tags => json_tags }
    end
  end

  ##
  # Create a new nearspeak tag in the system.
  def create
    text = params[:text]
    lang_code = params[:lang]
    purchase_id = params[:purchase_id]

    # optional
    gender = params[:gender]
    auth_token =  params[:auth_token]
    hardware_id = params[:hardware_id]
    hardware_type = params[:hardware_type]
    name = params[:name]
    parent_id = params[:parent_id]
    latitude = params[:lat]
    longitude = params[:lon]
    ble_major = params[:major]
    ble_minor = params[:minor]

    customer = nil

    error = []
    if text.nil?
      error << 'text'
    end

    if lang_code.nil?
      error << 'lang'
    end

    if purchase_id.nil?
      error << 'purchase_id'
    end

    # also require major und minor id by bluetooth beacons
    unless hardware_type.nil?
      if hardware_type == HardwaresHelper::TYPE_BLE
        if ble_major.nil?
          error << 'major'
        end

        if ble_minor.nil?
          error << 'minor'
        end
      end
    end

    if  error.length > 0
      return_error_infos(400, 'Request values are missing', 'InvalidRequest', error)
      return
    end

    unless TranslationsHelper.is_valid_language(lang_code)
      return_error_infos(400, 'Wrong language code', 'WrongLanguageCode', nil)
      return
    end

    unless auth_token.nil?
      customer_token = params[:auth_token].presence
      customer = customer_token && Customer.find_by_auth_token(customer_token)

      if customer && Devise.secure_compare(customer.get_devise_auth_token, customer_token)
        sign_in customer, store: false
      end
    end

    status, tag, error_msg, error_code = Tag.create_with_data(text, lang_code, purchase_id, gender, hardware_id, hardware_type, ble_major, ble_minor, name, parent_id, latitude, longitude, customer)

    if status.nil?
      return_error_infos(400, 'Error while creating new tag', 'CreationError', nil)
    else
      if status != 200
        return_error_infos(status, error_msg, error_code, nil)
      else
        if lang_code.nil?
          return_tag_infos(tag, nil)
        else
          return_tag_infos(tag, lang_code)
        end
      end
    end
  end

  ##
  # Add a hardware to a nearspeak tag.
  def add_hardware_id_to_tag
    tag = Tag.find_by_tag_identifier(params[:id])
    hardware_id = params[:hardware_id]
    hardware_type = params[:hardware_type]

    #optional
    latitude = params[:lat]
    longitude = params[:lon]
    ble_major = params[:major]
    ble_minor = params[:minor]

    if  hardware_id.nil?
      return_error_infos(400, 'Hardware ID is missing', 'HardwareIDMissing', nil)
      return
    end

    error = []

    if hardware_type.nil?
      error << 'hardware_type'
    end

    # also require major und minor id by bluetooth beacons
    unless hardware_type.nil?
      if hardware_type == HardwaresHelper::TYPE_BLE
        if ble_major.nil?
          error << 'major'
        end

        if ble_minor.nil?
          error << 'minor'
        end
      end
    end

    if  error.length > 0
      return_error_infos(400, 'Request values are missing', 'InvalidRequest', error)
      return
    end

    if tag.nil?
      return_error_infos(400, 'Tag not found', 'TagNotFound', nil)
    else
      status, tag, error_msg, error_code = tag.add_hardware_id_to_tag(hardware_id, hardware_type, ble_major, ble_minor, latitude, longitude)

      if status.nil?
        return_error_infos(400, 'Error while updating tag', 'InvalidRequest', nil)
      else

        if status != 200
          return_error_infos(status, error_msg, error_code, nil)
        else
          return_tag_infos(tag, nil)
        end
      end
    end
  end

  ##
  # Get all supported translation languages by bing back.
  def supported_language_codes
    language_codes = TranslationsHelper.supported_language_codes

    if language_codes.empty?
      return_error_infos(400, 'Error no supported languages', 'TranslationError', nil)
    else
      render :status => 200, :json => { :language_codes => language_codes }
    end
  end
  
  ##
  # Get all supported iBeacon UUIDs from the server.
  def get_all_uuids
    ble_uuids = Hardware.all_ble_uuids.map { |hw| hw.identifier }
    
    render :status => 200, :json => { :uuids => ble_uuids }
  end

  ### PRIVATE ###
  private

  ##
  # Creates json hash for linked tags.
  def create_linked_tag_infos(tag, language_code)
    return_tag = {}

    unless tag.nil?
      return_tag[:id] = tag.id
      return_tag[:tag_identifier] = tag.tag_identifier

      if language_code.nil? and !tag.original_name.nil?
        return_tag[:name] = tag.original_name.text.to_s
        return_tag[:lang] = tag.original_name.lang_code.to_s
      elsif !language_code.nil?
        return_tag[:name] = tag.get_name_translation(language_code)
        return_tag[:lang] = language_code
      end
    end

    return_tag
  end

  ##
  # Creates json hash for a tag.
  def create_tag_infos(tag, language_code)
    return_tag = {}

    # tag infos
    unless tag.nil?
      return_tag[:id] = tag.id
      return_tag[:tag_identifier] = tag.tag_identifier

      unless tag.description.nil? or tag.description.empty?
        return_tag[:description] = tag.description
      end

      unless tag.place.nil?
        return_tag[:places] = tag.place.id
      end

      # name
      # show original name if no lang_code is set
      if language_code.nil? and !tag.original_name.nil?
        return_tag[:name] = { :text => tag.original_name.text, :lang => tag.original_name.lang_code }
      elsif !language_code.nil? and tag.name_translations.count > 0
        return_tag[:name] = { :text => tag.get_name_translation(language_code), :lang => language_code }
      end

      # text_record infos
      unless tag.text_record.nil?
        unless tag.text_record.gender.nil?
          return_tag[:gender] = tag.text_record.gender
        end

        unless tag.text_record.image_url.empty?
          return_tag[:image_url] = tag.text_record.image_url
        end

        unless tag.text_record.text_url.empty?
          return_tag[:text_url] = tag.text_record.text_url
        end

        # show original text if no lang_code is set
        if language_code.nil? and !tag.text_record.original_text.nil?
          text = tag.text_record.original_text.text.to_s
          lang_code = tag.text_record.original_text.lang_code.to_s
        elsif !language_code.nil? and tag.text_record.translations.count > 0
          text = tag.text_record.get_translation(language_code)
          lang_code = language_code

          # convert to string
          text = text.to_s
        end

        unless text.nil?
          unless text.empty?
            return_tag[:translation] = { :text => text, :lang => lang_code }
          end
        end
      end

      # linked tags
      if tag.has_children?
        linked_tags = []
        tag.children.all.each { |t| linked_tags << create_linked_tag_infos(t, language_code) }
        return_tag[:linked_tags] = linked_tags
      end

      # parent tag
      unless tag.is_root?
        return_tag[:parent_tag] = create_linked_tag_infos(tag.parent, language_code)
      end

      # hardware
      unless tag.hardwares.nil? or tag.hardwares.count < 1
        hw_items = []
        tag.hardwares.each do |item|
          hw = {}

          hw[:type] = item.hardware_type
          hw[:identifier] = item.identifier

          if location = item.current_location
            hw[:latitude] = location.latitude
            hw[:longitude] = location.longitude
          end

          unless item.major.nil? and item.minor.nil?
            hw[:major] = item.major
            hw[:minor] = item.minor
          end

          hw_items << hw
        end
        return_tag[:hardware] = hw_items
      end
    end

    return_tag
  end

  ##
  # Return error messages in json format.
  def return_error_infos(status, error_message, error_code, values)
    if values.nil?
      render :status => status, :json => { :error => { :message => error_message, :code => error_code }}
    else
      render :status => status, :json => { :error => { :message => error_message, :values => values, :code => error_code }}
    end
  end

  ##
  # Returns the tag infos.
  def return_tag_infos(tag, language_code)
    if tag.nil?
      render :status => 400, :json => { :error => { :message => 'Tag not found', :code => 'InvalidRequest' }}
    else
      tag_infos = create_tag_infos(tag, language_code)

      render :status => 200, :json => { :tags => [tag_infos] }
    end
  end

  ##
  # Increments the tag scan counter.
  def tag_scanned(tag)
    unless tag.nil?
      if tag.scan_count.nil?
        tag.scan_count = 1
      else
        tag.scan_count += 1
      end

      tag.save
    end
  end
end