class PlacesController < ApplicationController
  before_action :authenticate_request

  def index
    authorize! :index, Place
    @places = get_places

    render template: 'places/index.json'
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
