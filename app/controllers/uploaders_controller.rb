class UploadersController < ApplicationController
  before_action :set_uploader, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, :only => [:create, :status, :setup, :earthquake_coming, :index]
  before_action :return_errors_unless_valid_service_key, :only => [:status, :setup, :earthquake_coming]
  before_action :return_errors_unless_valid_action_fields, only: :create_new_thing

  IFTTT_SERVICE_KEY = "yB4p8CgYVQShe0YP95ACy7GyOTWGCkrG9ysif9Q9J3S2URybiCNokUk7NvWMvB9H"
  
  # GET /uploaders
  # GET /uploaders.json
  def index
    @uploaders = Uploader.all
  end

  # GET /uploaders/1
  # GET /uploaders/1.json
  def show
  end

  # GET /uploaders/new
  def new
    @uploader = Uploader.new
  end

  # GET /uploaders/1/edit
  def edit
  end

  # POST /uploaders
  # POST /uploaders.json
  def create
	# 把訊息寫進 log 內, 可用heroku logs -a rescue-team 看.
    Rails.logger.info request.body.read
	@uploader = Uploader.new(uploader_params)
	@uploader.save
	
	# 通知 ifttt 來收新資料
	
	# 傳回 response, 讓 push 端知道我們成功收到訊息了.
	render :xml => "<?xml version=\"1.0\" encoding=\"utf-8\" ?> <Data><Status>true</Status></Data>"
  end
  
  # POST /ifttt/v1/status, return OK so ifttt will hit /ifttt/v1/test/setup (uploaders#setup)
  def status
    head :ok
  end

  # P/ifttt/v1/test/setup (uploaders#setup)
  def setup
    data = {
      samples: {
		"triggers": {
			"earthquake_coming": {
				"category": "台北市"
			}
		}
      }
    }
	render plain: { data: data }.to_json
  end

  def earthquake_coming
    data = Uploader.all.sort_by(&:created_at).reverse.map(&:to_json).first(params[:limit] || 50)
    render plain: { data: data }.to_json
  end


  # PATCH/PUT /uploaders/1
  # PATCH/PUT /uploaders/1.json
  def update
    respond_to do |format|
      if @uploader.update(uploader_params)
        format.html { redirect_to @uploader, notice: 'Uploader was successfully updated.' }
        format.json { render :show, status: :ok, location: @uploader }
      else
        format.html { render :edit }
        format.json { render json: @uploader.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploaders/1
  # DELETE /uploaders/1.json
  def destroy
    @uploader.destroy
    respond_to do |format|
      format.html { redirect_to uploaders_url, notice: 'Uploader was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_uploader
      @uploader = Uploader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def uploader_params
      params.require(:uploader).permit(:time, :content, :place)
    end
	
	def return_errors_unless_valid_service_key
		unless request.headers["HTTP_IFTTT_SERVICE_KEY"] == IFTTT_SERVICE_KEY
		return render plain: { errors: [ { message: "401" } ] }.to_json, status: 401
		end
	end

	def return_errors_unless_valid_action_fields
		if params[:actionFields] && params[:actionFields][:invalid] == "true"
		return render plain: { errors: [ { status: "SKIP", message: "400" } ] }.to_json, status: 400
		end
	end


end
