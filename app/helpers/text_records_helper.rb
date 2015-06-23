##
# The TextRecordsHelper module.
module TextRecordsHelper
  
  ##
  # Return all valid gender types including their names.
  def self.gender_types
    [[I18n.t("tag_gender_male"), 'm'], [I18n.t("tag_gender_female"), 'f']]
  end
end
