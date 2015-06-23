##
# The CustomersHelper module.
module CustomersHelper
  
  ##
  # Check if the given language code is valid.
  #
  # @param language_code [String] The language code to check.
  # @return True or false.
  def self.is_valid_language(language_code)
    if language_code.nil?
      return false
    end

    if supported_cms_languages.include?(language_code)
      return true
    end

    return false
  end

  ##
  # Get all supported interface languages for the CMS.
  def self.supported_cms_languages
    # available languages
    %w(en de)
  end

  ##
  # Get all supported interface languages for the CMS including their names.
  def self.supported_cms_languages_with_names
    [%w(Deutsch de), %w(English en)]
  end

  ##
  # Get the name of the language via the given language code.
  #
  # @param language_code [String] The language code.
  def self.name_from_language_code(language_code)
    if language_code.nil?
      return ''
    end

    supported_cms_languages_with_names.each do |lang_array|
      if lang_array[1].eql? language_code
        return lang_array[0]
      end
    end

    unless name.nil?
      return name
    end

    return language_code
  end
end
