##
# The TranslationsHelper module.
module TranslationsHelper
  
  ##
  # Check if the given language code is valid.
  #
  # @param lang_code [String] The langecode which should be checked.
  def self.is_valid_language(lang_code)
    languages = supported_language_codes

    cut_lang_code = cut_country(lang_code)
    if languages.include?(cut_lang_code)
      return true
    else
      return false
    end
  end

  ##
  # Remove the country from the language code, because bing translate doesn't support this.
  # example: en_US -> en
  # example: en-US -> en
  #
  # @param lang_code [String] The language code which should be cut.
  def self.cut_country(lang_code)
    if lang_code == nil
      return nil
    end

    language = lang_code.split("-")[0].split("_")[0]
  end

  ##
  # Get all currently supported language codes.
  def self.supported_language_codes
    #require 'bing_translator'

    #translator = BingTranslator.new(BING_CLIENT_ID_DEV, BING_CLIENT_SECRET_DEV)
    #languages = translator.supported_language_codes
    #Rails.logger.info('DBG: supported languages: ' + languages.to_s)

    # http://msdn.microsoft.com/en-us/library/hh456380.aspx

    # update this string from time to time, don't query every time.
    languages = %w(ar bg ca zh-CHS zh-CHT cs da nl en et fi fr de el ht he hi mww hu id it ja tlh tlh-Qaak ko lv lt ms mt no fa pl pt ro ru sk sl es sv th tr uk ur vi cy)
  end

  ##
  # Get all currently supported language code including their names.
  def self.supported_language_codes_with_names
    [%w(Arabic ar),
     %w(Bulgarian bg),
     %w(Catalan ca),
     %w(Chinese Simplified zh-CHS),
     %w(Chinese Traditional zh-CHT),
     %w(Czech cs),
     %w(Danish da),
     %w(Dutch nl),
     %w(English en),
     %w(Estonian et),
     %w(Finnish fi),
     %w(French fr),
     %w(German de),
     %w(Greek el),
     %w(Haitian Creole ht),
     %w(Hebrew he),
     %w(Hindi hi),
     %w(Hmong Daw mww),
     %w(Hungarian hu),
     %w(Indonesian id),
     %w(Italian it),
     %w(Japanese ja),
     %w(Klingon tlh),
     %w(Klingon (pIqaD) tlh-Qaak),
     %w(Korean ko),
     %w(Latvian lv),
     %w(Lithuanian lt),
     %w(Malay ms),
     %w(Maltese mt),
     %w(Norwegian no),
     %w(Persian fa),
     %w(Polish pl),
     %w(Portuguese pt),
     %w(Romanian ro),
     %w(Russian ru),
     %w(Slovak sk),
     %w(Slovenian sl),
     %w(Spanish es),
     %w(Swedish sv),
     %w(Thai th),
     %w(Turkish tr),
     %w(Ukrainian uk),
     %w(Urdu ur),
     %w(Vietnamese vi),
     %w(Welsh cy)]
  end
end
