##
# The NameTranslation model handles name translations for a nearspeak tag.
class NameTranslation < ActiveRecord::Base
  validates :lang_code, presence: true
  validates :text, presence: true

  belongs_to :tag

  before_save :store_original_as_translation

  ### PRIVATE ###
  private

  ##
  # Also store the original text as translation.
  def store_original_as_translation
    unless self.original_name_id.nil?
      self.tag_id = self.original_name_id
    end
  end
end
