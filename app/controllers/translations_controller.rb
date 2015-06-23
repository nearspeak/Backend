##
# The translations controller.
class TranslationsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_translation, only: [:show, :edit, :update, :destroy]

  # GET /translations
  # GET /translations.json
  def index
    if current_customer.role == 'admin'
      @translations = Translation.all
    else
      # output customers translations
      @translations = Translation.joins(text_record: [:tag]).where('Tags.customer_id' => current_customer)
    end
  end

  # GET /translations/1
  # GET /translations/1.json
  def show
  end

  # GET /translations/new
  def new
    @translation = Translation.new
    @tag_id = params['tag_id']
    @translation_langs = TranslationsHelper.supported_language_codes_with_names

    # if this is the first translation show a text input field
    unless @tag_id.nil?
      tag = Tag.find_by_id(@tag_id)
      text_record = tag.text_record

      if text_record.nil?
        @editTagForm = true
      else
        translations = text_record.translations

        if translations.nil?
          @editTagForm = true
        else
          @editTagForm = false
        end
      end
    end
  end

  # GET /translations/1/edit
  def edit
    @tag_id = params['tag_id']
    @translation_langs = TranslationsHelper.supported_language_codes_with_names
    @editTagForm = true
  end

  # POST /translations
  # POST /translations.json
  def create
    @translation_langs = TranslationsHelper.supported_language_codes_with_names
    @tag_id = params['translation']['tag_id']
    @translation = Translation.new()
    @editTagForm = false

    unless @tag_id.nil?
      tag = Tag.find_by_id(@tag_id)
      text_record = tag.text_record
      result = false

      if text_record.nil?
        # if there is no text record create a new one

        @editTagForm = true
        original_text = Translation.create(translation_params)
        result = original_text.save

        if result
          text_record = TextRecord.new(original_text: original_text, gender: 'm')
          result = text_record.save

          if result
            tag.text_record = text_record
          end
        end
      else
        original_text = text_record.original_text.text
        original_lang_code = text_record.original_text.lang_code

        new_lang_code = params[:translation][:lang_code].to_s

        unless new_lang_code.nil? or new_lang_code.empty?
          new_text = translate_text(original_text, original_lang_code, new_lang_code)

          @translation = Translation.new(text: new_text, lang_code: new_lang_code)
          result = @translation.save
          text_record.translations << @translation
        end
      end
    end

    respond_to do |format|
      if result
        format.html { redirect_to tag_path(@tag_id), notice: 'Translation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @translation }
      else
        format.html { render action: 'new' }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /translations/1
  # PATCH/PUT /translations/1.json
  def update
    @translation_langs = TranslationsHelper.supported_language_codes_with_names
    @tag_id = params['translation']['tag_id']
    @editTagForm = true

    respond_to do |format|
      if @translation.update(translation_params)
        format.html { redirect_to tag_path(@tag_id), notice: 'Translation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /translations/1
  # DELETE /translations/1.json
  def destroy
    tag_id = params['tag_id']

    @translation.destroy
    respond_to do |format|
      format.html { redirect_to tag_path(tag_id), notice: 'Translation was successfully removed.' }
      format.json { head :no_content }
    end
  end

  ### PRIVATE ###
  private
  
  ##
  # Use callbacks to share common setup or constraints between actions.
  def set_translation
    if current_customer.role == 'admin'
      @translation = Translation.find(params[:id])
    else
      @translation = Translation.joins(text_record: [:tag]).where('Tags.customer_id = ? AND translations.id = ?', current_customer, params[:id]).first
    end
  end

  ##
  # Never trust parameters from the scary internet, only allow the white list through.
  def translation_params
    params.require(:translation).permit(:lang_code, :text, :count)
  end

  ##
  # Translates a given text into a new language.
  #
  # @param text [String] The text.
  # @param original_lang_code [String] The original text from the given text.
  # @param lang_code [String] The language code to translate the text into.
  # @return [String] The translated text.
  def translate_text(text, original_lang_code, lang_code)
    unless text.nil? or lang_code.nil? or original_lang_code.nil?
      translator = BingTranslator.new(BING_CLIENT_ID_DEV, BING_CLIENT_SECRET_DEV)
      translator.translate(text, :from => original_lang_code, :to => lang_code)
    end
  end
end
