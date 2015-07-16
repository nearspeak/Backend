##
# The tags controller.
class TagsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /Tags
  # GET /Tags.json
  def index
    if current_customer.role == 'admin'
      @tags = Tag.all
    else
      @tags = Tag.my(current_customer)
    end
  end

  # GET /Tags/1
  # GET /Tags/1.json
  def show
    unless @tag.nil?
      @text_record = @tag.text_record

      unless @text_record.nil?
        @translations = @text_record.translations
      end

      @name_translations = @tag.name_translations

      if @tag.hardwares.count > 0
        @hardwares = @tag.hardwares

        # generate google map location
        @showMap = false
        
        @markers = []
        
        @tag.hardwares.with_location().each do | hardware |
          unless hardware.current_location.nil?
            @showMap = true

            @markers << { :lat => hardware.current_location.latitude, :lng => hardware.current_location.longitude }
          end
        end
        
      end
    end
  end

  # GET /Tags/new
  def new
    @tag = Tag.new
    if params[:mode] == 'in_mode'
      @tag.place_id = params['place_id']
    end

    @tag_limit_reached = true
    
    if Tag.my(current_customer).count <= MAX_TAG_PER_CUSTOMER
      @tag_limit_reached = false
    end
  end

  # GET /Tags/1/edit
  def edit
  end

  # POST /Tags
  # POST /Tags.json
  def create
    @tag = Tag.new(tag_params)
    @tag.customer = current_customer

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tag }
      else
        format.html { render action: 'new' }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /Tags/1
  # PATCH/PUT /Tags/1.json
  def update
    unless @tag.nil?
      respond_to do |format|
        if @tag.update(tag_params)
          format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @tag.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Tags/1
  # DELETE /Tags/1.json
  def destroy
    unless @tag.nil?
      @tag.destroy
      respond_to do |format|
        format.html { redirect_to tags_url }
        format.json { head :no_content }
      end
    end
  end

  ### PRIVATE ###
  private
  
  ##
  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    if current_customer.role == 'admin'
      @tag = Tag.find(params[:id])
    else
      @tag = Tag.where('id = ? AND customer_id = ?', params[:id], current_customer).first
    end
  end

  ##
  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    params.require(:tag).permit(:places_id, :name, :description, :tag_identifier, :original_name, :parent_id, :active, :active_start_time, :active_stop_time, :active_time, :active_date, :active_start_date, :active_stop_date)
  end
end
