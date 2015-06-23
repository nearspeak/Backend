##
# The PurchasesHelper module.
module PurchasesHelper
  
  ##
  # Valid a given purchase id.
  #
  # @param purchase_id [String] The purchase it which should be validated.
  def self.validate_purchase_id(purchase_id)
    if purchase_id.size != 36
      # check if upgrade id
      reg_upgrade = /^upgrade[0-9]{4}$/

      return (reg_upgrade.match(purchase_id)) ? true : false
    end

    reg = /[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$/

    return (reg.match(purchase_id)) ? true : false
  end
end
