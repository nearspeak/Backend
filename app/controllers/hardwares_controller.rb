##
# The hardware controller.
class HardwaresController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_hardware, only: [:show, :edit, :update, :destroy]

  # GET /hardwares
  # GET /hardwares.json
  def index
    # @hardwares = Hardware.all
  end

  # GET /hardwares/1
  # GET /hardwares/1.json
  def show
  end

  # GET /hardwares/new
  def new
    @hardware = Hardware.new
    @tag_id = params['tag_id']
    @hardware_types = HardwaresHelper.supported_hardware_types_with_names
  end

  # GET /hardwares/1/edit
  def edit
    @tag_id = params['tag_id']
    @hardware_types = HardwaresHelper.supported_hardware_types_with_names
  end

  # POST /hardwares
  # POST /hardwares.json
  def create
    #TODO: if hardware type is iBeacon, major id and minor id is required

    @hardware_types = HardwaresHelper.supported_hardware_types_with_names

    @tag_id = params['hardware']['tag_id']

    @hardware = Hardware.new(hardware_params)
    @hardware.identifier = @hardware.identifier.upcase

    result = @hardware.save

    if result
      unless @tag_id.nil?
        tag = Tag.find_by_id(@tag_id)
        tag.hardwares << @hardware
      end
    end

    respond_to do |format|
      if result
        format.html { redirect_to tag_path(@tag_id), notice: 'Hardware was successfully created.' }
        format.json { render :show, status: :created, location: @hardware }
      else
        format.html { render :new }
        format.json { render json: @hardware.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hardwares/1
  # PATCH/PUT /hardwares/1.json
  def update
    @tag_id = params['hardware']['tag_id']

    respond_to do |format|
      if @hardware.update(hardware_params)
        format.html { redirect_to tag_path(@tag_id), notice: 'Hardware was successfully updated.' }
        format.json { render :show, status: :ok, location: @hardware }
      else
        format.html { render :edit }
        format.json { render json: @hardware.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hardwares/1
  # DELETE /hardwares/1.json
  def destroy
    tag_id = params['tag_id']

    @hardware.destroy
    respond_to do |format|
      format.html { redirect_to tag_path(tag_id), notice: 'Hardware was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  ### PRIVATE ###
  private
  
  ##
  # Use callbacks to share common setup or constraints between actions.
  def set_hardware
    if current_customer.role == 'admin'
      @hardware = Hardware.find(params[:id])
    else
      @hardware = Hardware.joins(:tag).where('Tags.customer_id = ? AND hardwares.id = ?', current_customer, params[:id]).first
    end
  end

  ##
  # Never trust parameters from the scary internet, only allow the white list through.
  def hardware_params
    params.require(:hardware).permit(:hardware_type, :identifier, :major, :minor, :tag_id)
  end
end
