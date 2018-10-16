require 'rcap'

class UploadersController < ApplicationController
  before_action :set_uploader, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, :only => [:create, :status, :setup, :earthquake_coming, :index]
  before_action :return_errors_unless_valid_service_key, :only => [:status, :setup, :earthquake_coming]
  before_action :return_errors_unless_valid_action_fields, only: :create_new_thing

  IFTTT_REALTIME_NOTIFICATION_URL = "https://realtime.ifttt.com/v1/notifications"
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
    #Rails.logger.info request.body.read
	
	# parse 警訊, 翻譯成 object 存起來.
	#@doc = Nokogiri::XML(request.body.read)
	alert = RCAP::Alert.from_xml(request.body.read)
	Rails.logger.info alert.sent
	#Rails.logger.info alert.to_h['identifier']
	#Rails.logger.info alert.infos

	# 把訊息寫進 database 內, 等 ifttt 來收新資料.
	alert.infos.first.parameters.each do |para|
		if para.to_s =~ /\"/
			ary = para.to_s.split(";")
			#ary[0] #級數
			#ary[1] #城市
			Rails.logger.info ary[1].gsub("\"", "") + " " + ary[0].split(" ")[1]
			@uploader = Uploader.new :place => ary[1].gsub("\"", ""), :content => ary[0].split(" ")[1], :time => alert.sent
			@uploader.save
		end
	end
	#hash["alert"]["info"]["description"]
		

	# 處理 ruby on rails 網頁介面的資料
	#@uploader = Uploader.new(uploader_params)
	#@uploader.save
	
	# 通知 ifttt 來收新資料
	Rails.logger.info "Ping IFTTT..."
	Thread.new {ping_ifttt}
	
	# 傳回 response, 讓 push 端知道我們成功收到訊息了.
	render :xml => "<?xml version=\"1.0\" encoding=\"utf-8\" ?> <Data><Status>true</Status></Data>"
  end
  
  def ping_ifttt
	require 'net/http'
	require 'uri'
	require 'json'
	
	uri = URI.parse(IFTTT_REALTIME_NOTIFICATION_URL)
	
	header = {
		'IFTTT-Service-Key'=>IFTTT_SERVICE_KEY,
		'Accept'=>'application/json',
		'Accept-Charset'=>'utf-8',
		'Accept-Encoding'=>'gzip, deflate',
		'Content-Type'=>'application/json'
	}
	body = { 
		data: [
			{
				"trigger_identity": "e3145801f68e4e08072ebb10a5bcdecc00bd8233"
			}
		]
	}
	Rails.logger.info header
	Rails.logger.info body.to_json
	# Create the HTTP objects
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	request = Net::HTTP::Post.new(uri.request_uri, header)
	request.body = body.to_json

	# Send the request
	response = http.request(request)
	Rails.logger.info response.read_body
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
				"place": "臺北市"
			}
		}
      }
    }
	render plain: { data: data }.to_json
  end

  def earthquake_coming
	trigger_id = params['trigger_identity']
	Rails.logger.info "trigger_identity: " + trigger_id
	city = params['triggerFields']['place']
    #data = Uploader.all.sort_by(&:created_at).reverse.map(&:to_json).first(params[:limit] || 50)
	data = Uploader.where(:place => city).sort_by(&:created_at).reverse.map(&:to_json).first(params[:limit] || 50)
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
