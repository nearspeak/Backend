##
# The Purchase model handles purchase related informations for the nearspeak tag.
class Purchase < ActiveRecord::Base
  validates :purchase_id, presence: true

  belongs_to :text_record

  ##
  # Check if there are enough purchases available.
  #
  # @param purchase_id [String] The purchase id.
  def self.check_purchases(purchase_id)
    if PurchasesHelper.validate_purchase_id(purchase_id)
      purchases = Purchase.where('purchase_id = ?', purchase_id)

      unless purchases.nil?
        return purchases.length
      end
    end

    return MAX_TAGS_PER_PURCHASE_ID
  end
end
