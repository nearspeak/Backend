##
# The HardwaresHelper module.
module HardwaresHelper
  # QR Code
  TYPE_QR = 'qr'
  
  # NFC tag
  TYPE_NFC = 'nfc'
  
  # Bluetooth LE beacon
  TYPE_BLE = 'ble-beacon'

  ##
  # Check if the given hardware type is valid.
  #
  # @param hardware_type [String] The hardware type which should be validated.
  def self.validate_hardware_type(hardware_type)
    if hardware_type == TYPE_NFC or hardware_type == TYPE_BLE or hardware_type == TYPE_QR
      return true
    end
    return false
  end

  ##
  # Get all valid and currently supported hardware types.
  def self.supported_hardware_types
    [TYPE_QR, TYPE_NFC, TYPE_BLE]
  end

  ##
  # Get all valid and currently supported hardware types including their names.
  def self.supported_hardware_types_with_names
    [['QR-Code', TYPE_QR], ['NFC', TYPE_NFC], ['iBeacon', TYPE_BLE]]
  end
end
