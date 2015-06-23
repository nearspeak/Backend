##
# The name translations controller.
class NameTranslationsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_name_translation, only: [:show, :edit, :update, :destroy]

  # GET /name_translations
  # GET /name_translations.json
  def index
    if current_customer.role = 'admin'
      @name_translations = NameTranslation.all
    else
      #output customers name translations
      @name_translations = NameTranslation.joins(:tag).where('Tags.customer_id' => current_customer)
    end
  end

  # GET /name_translations/1
  # GET /name_translations/1.json
  def show
  end

  # GET /name_translations/new
  def new
    @name_translation = NameTranslation.new
    @tag_id = params['tag_id']
    @translation_langs = TranslationsHelper.supported_language_codes_with_names
    @editTagForm = false

    # if this is the first name set it as original name and show a text field
    unless @tag_id.nil?
      tag = Tag.find_by_id(@tag_id)

      if tag.original_name.nil?
        @editTagForm = true
      end
    end
  end

  # GET /name_translations/1/edit
  def edit
    @tag_id = params['tag_id']
    @translation_langs = TranslationsHelper.supported_language_codes_with_names
    @editTagForm = true
  end

  # POST /name_translations
  # POST /name_translations.json
  def create
    @translation_langs = TranslationsHelper.supported_language_codes_with_names
    @editTagForm = false
    @tag_id = params['name_translation']['tag_id']
    result = false

    unless @tag_id.nil?
      tag = Tag.find_by_id(@tag_id)
      @name_translation = NameTranslation.new(name_translation_params)

      # if there is no original name set this one as original name
      if tag.original_name.nil?
        lang_code = params[:name_translation][:lang_code].to_s
        text = params[:name_translation][:text].to_s

        unless lang_code.empty? or text.empty?
          @name_translation = NameTranslation.new(text: text, lang_code: lang_code)
          result = @name_translation.save
        end

        if result
          tag.original_name = @name_translation
        end
      else
        original_text = tag.original_name.text
        original_lang_code = tag.original_name.lang_code

        new_lang_code = params[:name_translation][:lang_code].to_s

        unless new_lang_code.nil? or new_lang_code.empty?
          new_text = translate_text(original_text, original_lang_code, new_lang_code)

          @name_translation = NameTranslation.new(text: new_text, lang_code: new_lang_code)
          result = @name_translation.save

          if result
            tag.name_translations << @name_translation
          end
        end
      end
    end

    respond_to do |format|
      if result
        format.html { redirect_to tag_path(@tag_id), notice: 'Name translation was successfully created.' }
        format.json { render :show, status: :created, location: @name_translation }
      else
        format.html { redirect_to new_name_translation_path(:mode => 'in_mode', :tag_id => @tag_id) }
        format.json { render json: @name_translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /name_translations/1
  # PATCH/PUT /name_translations/1.json
  def update
    @tag_id = params['name_translation']['tag_id']
    @editTagForm = true

    respond_to do |format|
      if @name_translation.update(name_translation_params)
        format.html { redirect_to tag_path(@tag_id), notice: 'Name translation was successfully updated.' }
        format.json { render :show, status: :ok, location: @name_translation }
      else
        format.html { render :edit }
        format.json { render json: @name_translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /name_translations/1
  # DELETE /name_translations/1.json
  def destroy
    tag_id = params['tag_id']

    @name_translation.destroy
    respond_to do |format|
      format.html { redirect_to tag_path(tag_id), notice: 'Name translation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  ### PRIVATE ###
  private
  
  ##
  # Use callbacks to share common setup or constraints between actions.
  def set_name_translation
    if current_customer.role == 'admin'
      @name_translation = NameTranslation.find(params[:id])
    else
      @name_translation = NameTranslation.joins(:tag).where('Tags.customer_id = ? AND name_translations.id = ?', current_customer, params[:id]).first
    end

  end

  ##
  # Never trust parameters from the scary internet, only allow the white list through.
  def name_translation_params
    params.require(:name_translation).permit(:lang_code, :text)
  end

  ##
  # Translates a given name into a new language.
  #
  # @param text [String] The name.
  # @param original_lang_code [String] The original text from the given name.
  # @param lang_code [String] The language code to translate the name into.
  # @return [String] The translated name.
  def translate_text(text, original_lang_code, lang_code)
    unless text.nil? or lang_code.nil? or original_lang_code.nil?
      translator = BingTranslator.new(BING_CLIENT_ID_DEV, BING_CLIENT_SECRET_DEV)
      translator.translate(text, :from => original_lang_code, :to => lang_code)
    end
  end
end
