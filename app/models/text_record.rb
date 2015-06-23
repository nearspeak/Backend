##
# The TextRecord model handels all text related informations of a nearspeak tag.
class TextRecord < ActiveRecord::Base
  validates :original_text, presence: true
  validates_inclusion_of :gender, :in => %w( m f )

  belongs_to :tag
  has_one :original_text, class_name: 'Translation', foreign_key: 'original_text_id', dependent: :destroy
  has_many :translations, dependent: :destroy
  has_one :purchase, dependent: :nullify

  before_save :store_original_as_translation

  accepts_nested_attributes_for :original_text
  accepts_nested_attributes_for :translations
  accepts_nested_attributes_for :purchase

  ##
  # Returns the translated text, or the original text if the language is the current
  #
  # @param lang_code [String] The language code.
  def get_translation(lang_code)
    # format language code to a valid bing translate format
    lang_code_cut = TranslationsHelper.cut_country lang_code
    if lang_code_cut.nil?
      return nil
    end

    # check if this is a valid language code
    unless TranslationsHelper.is_valid_language lang_code_cut
      return nil
    end

    # check if original text is in the new language
    unless original_text.nil?
      lang_code_original_cut = TranslationsHelper.cut_country original_text.lang_code

      if original_text.lang_code == lang_code
        return original_text.text
      elsif original_text.lang_code == lang_code_cut
        add_translation(original_text.text, lang_code)
        return original_text.text
      elsif lang_code_original_cut == lang_code_cut
        add_translation(original_text.text, lang_code)
        return original_text.text
      end
    end

    # check if translation is already available, if not translate it via bing
    trans = translations.find_by_lang_code(lang_code)
    if trans.nil?
      trans_cut = translations.find_by_lang_code(lang_code_cut)

      # check if there is a translation only with the language code, without country code
      if trans_cut.nil?
        return translate_into_lang_code(lang_code)
      else
        add_translation(trans_cut.text, lang_code)
        return trans_cut.text
      end

      return translate_into_lang_code(lang_code)
    else
      return trans.text
    end
  end

  ##
  # Returns the original text.
  def get_original_text
    original_text.text
  end

  ##
  # Returrns the image url.
  def image_url
    image_uri
  end

  ##
  # Returns the text url.
  def text_url
    link_uri
  end

  ### PRIVATE ###
  private

  ##
  # Also store the original text as translation.
  def store_original_as_translation
    unless self.original_text.nil?
      self.translations << self.original_text
    end
  end

  ##
  # Use bing translate to add new translations for the text.
  #
  # @param lang_code [String] The language code.
  def translate_into_lang_code(lang_code)
    unless lang_code.nil?
      # if the text is a speaking business card don't translate
      if original_text.text.start_with?('BEGIN:VCARD')
        text = original_text.text
        add_translation(text, lang_code)
      else
        require 'bing_translator'

        original_translation_code = TranslationsHelper.cut_country original_text.lang_code
        to_translation_code = TranslationsHelper.cut_country lang_code

        translator = BingTranslator.new(BING_CLIENT_ID_DEV, BING_CLIENT_SECRET_DEV)

        text = translator.translate original_text.text, :from => original_translation_code, :to => to_translation_code
        add_translation(text, lang_code)
      end

      return text
    end
  end

  ##
  # Add new translation into the system.
  #
  # @param lang_code [String] The language code.
  def add_translation(text, lang_code)
    translation = Translation.create(:text => text, :lang_code => lang_code)

    translations << translation
  end
end