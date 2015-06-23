##
# The places controller.
class PlacesController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_place, only: [:show, :edit, :update, :destroy]

  # GET /places
  # GET /places.json
  def index
    if current_customer.role == 'admin'
      @places = Place.all
    else
      @places = Place.my(current_customer)
    end
  end

  # GET /places/1
  # GET /places/1.json
  def show
    @tags = @place.tags
  end

  # GET /places/new
  def new
    @place = Place.new
    
    # default location: Mopius HQ
    set_default_location
  end

  # GET /places/1/edit
  def edit
    if @place.latitude.nil? or @place.longitude.nil?
      set_default_location
    end
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(place_params)
    @place.customer = current_customer

    respond_to do |format|
      if @place.save
        format.html { redirect_to @place, notice: 'Place was successfully created.' }
        format.json { render action: 'show', status: :created, location: @place }
      else
        format.html { render action: 'new' }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to @place, notice: 'Place was successfully updated.' }
        format.json { head :no_content }
      else
        if @place.latitude.nil? or @place.longitude.nil?
          set_default_location
        end
        
        format.html { render action: 'edit' }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url }
      format.json { head :no_content }
    end
  end

  ### PRIVATE ###
  private
  
  ##
  # Use callbacks to share common setup or constraints between actions.
  def set_place
    if current_customer.role == 'admin'
      @place = Place.find(params[:id])
    else
      @place = Place.where('id = ? AND customer_id = ?', params[:id], current_customer).first
    end
  end

  ##
  # Never trust parameters from the scary internet, only allow the white list through.
  def place_params
    params.require(:place).permit(:name, :description, :image, :latitude, :longitude)
  end
  
  ##
  # Sthe the default location, to the Mopius HQ.
  def set_default_location
    @place.latitude = 48.168739
    @place.longitude = 16.333480
  end
end
