##
# The text records controller.
class TextRecordsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_text_record, only: [:show, :edit, :update, :destroy]

  # GET /text_records
  # GET /text_records.json
  def index
    if current_customer.role == 'admin'
      @text_records = TextRecord.all
    else
      @text_records = TextRecord.joins(:tag).where('Tags.customer_id' => current_customer)
    end
  end

  # GET /text_records/1
  # GET /text_records/1.json
  def show
  end

  # GET /text_records/new
  def new
    @text_record = TextRecord.new
  end

  # GET /text_records/1/edit
  def edit
    @tag_id = params['tag_id']
  end

  # POST /text_records
  # POST /text_records.json
  def create
    @text_record = TextRecord.new(text_record_params)

    respond_to do |format|
      if @text_record.save
        format.html { redirect_to @text_record, notice: 'Text record was successfully created.' }
        format.json { render action: 'show', status: :created, location: @text_record }
      else
        format.html { render action: 'new' }
        format.json { render json: @text_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /text_records/1
  # PATCH/PUT /text_records/1.json
  def update
    tag_id = params['text_record']['tag_id']

    respond_to do |format|
      if @text_record.update(text_record_params)
        format.html { redirect_to tag_path(tag_id), notice: 'Text record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @text_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /text_records/1
  # DELETE /text_records/1.json
  def destroy
    @text_record.destroy
    respond_to do |format|
      format.html { redirect_to text_records_url }
      format.json { head :no_content }
    end
  end

  ### PRIVATE ###
  private
  
  ##
  # Use callbacks to share common setup or constraints between actions.
  def set_text_record
    if current_customer.role == 'admin'
      @text_record = TextRecord.find(params[:id])
    else
      @text_record = TextRecord.joins(:tag).where('Tags.customer_id = ? AND text_records.id = ?',current_customer, params[:id]).first
    end
  end

  ##
  # Never trust parameters from the scary internet, only allow the white list through.
  def text_record_params
    params.require(:text_record).permit(:image_uri, :link_uri, :gender, :tag_id)
  end
end
