class ClientsController < ApplicationController
  before_action :authenticate_request

  def index
    authorize! :index, Client
    @clients = get_clients

    render template: 'clients/index.json'
  end

  def show
    authorize! :show, Client
    @client = Client.find_by id: params[:id]

    if @client
      render template: 'clients/show.json'
    else
      head :not_found
    end
  end

  def create
    authorize! :create, Client
    @client = Client.new client_params
    @client.creator = current_user

    if @client.save
      render template: 'clients/show.json'
    else
      render json: @client.errors
    end
  end

  def update
    @client = Client.find_by id: params[:id]

    if @client
      @client.assign_attributes client_updatabe_params
      authorize! :update, @client

      if @client.save
        render template: 'clients/show.json'
      else
        render json: @client.errors
      end
    else
      head :not_found
    end
  end

  private

  def get_clients
    params[:search] || params[:ordered] || params[:paginated] ? Client.filter(params.slice(:search, :ordered, :paginated)) : Client.all
  end

  def client_params
    params.require(:client).permit(:firstname, :lastname, :address_line_1, :address_line_2, :telephone_1, :telephone_2, :id_name, :trust_level)
  end

  def client_updatabe_params
    params.require(:client).permit(:firstname, :lastname, :address_line_1, :address_line_2, :telephone_1, :telephone_2, :id_name, :trust_level, :active)
  end

end
