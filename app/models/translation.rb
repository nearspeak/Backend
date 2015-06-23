##
# The Translation model handels all translation related stuff for the nearspeak tag.
class Translation < ActiveRecord::Base
  validates :lang_code, presence: true
  validates :text, presence: true

  belongs_to :text_record
end