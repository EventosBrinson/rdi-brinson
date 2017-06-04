class PlacesController < ApplicationController
  before_action :authenticate_request

  def index
    authorize! :index, Place

    if params[:client_id]
      @client = Client.find_by id: params[:client_id]

      if @client
        authorize! :show, @client
        @places = get_places

        render template: 'places/index.json'
      else
        head :not_found
      end
    else
      @places = get_places
      render template: 'places/index.json'
    end
  end

  private

  def get_places
    if params[:search] || params[:ordered] || params[:paginated]
      if params[:client_id]
        @client.places.filter(params.slice(:search, :ordered, :paginated))
      elsif current_user.admin? || current_user.staff? and params[:all]
        Place.filter(params.slice(:search, :ordered, :paginated))
      else
        current_user.places.filter(params.slice(:search, :ordered, :paginated))
      end
    else
      if params[:client_id]
        @client.places
      elsif current_user.admin? || current_user.staff? and params[:all]
        Place.all
      else
        current_user.places
      end
    end
  end
end
