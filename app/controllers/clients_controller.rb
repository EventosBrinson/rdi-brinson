class ClientsController < ApplicationController
  before_action :authenticate_request

  def index
    authorize! :index, Client
    @clients = get_clients

    render template: 'clients/index.json'
  end

  def show
    @client = Client.find_by id: params[:id]

    if @client
      authorize! :show, @client

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
    if params[:search] || params[:ordered] || params[:paginated]
      if current_user.admin? || current_user.staff? and params[:all]
        Client.filter(params.slice(:search, :ordered, :paginated))
      else
        current_user.clients.filter(params.slice(:search, :ordered, :paginated))
      end
    else
      if current_user.admin? || current_user.staff? and params[:all]
        Client.all
      else
        current_user.clients
      end
    end
  end

  def client_params
    params.require(:client).permit(:firstname, :lastname, :address_line_1, :address_line_2, :telephone_1, :telephone_2, :id_name, :trust_level)
  end

  def client_updatabe_params
    params.require(:client).permit(:firstname, :lastname, :address_line_1, :address_line_2, :telephone_1, :telephone_2, :id_name, :trust_level, :active)
  end

end
