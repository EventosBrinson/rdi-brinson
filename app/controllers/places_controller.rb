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

  def show
    @place = Place.find_by id: params[:id]

    if @place
      authorize! :show, @place

      render template: 'places/show.json'
    else
      head :not_found
    end
  end

  def create
    @place = Place.new place_params

    if @place.validate
      authorize! :create, @place

      @place.save

      render template: 'places/show.json'
    else
      render json: @place.errors
    end
  end

  def update
    @place = Place.find_by id: params[:id]

    if @place
      @place.assign_attributes place_updateable_params
      authorize! :update, @place

      if @place.save
        render template: 'places/show.json'
      else
        render json: @place.errors
      end
    else
      head :not_found
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
        Place.all.order(:name)
      else
        current_user.places.order(:name)
      end
    end
  end

  def place_params
    params.require(:place).permit(:name, :street, :inner_number, :outer_number, :neighborhood, :postal_code, :client_id)
  end

  def place_updateable_params
    params.require(:place).permit(:name, :street, :inner_number, :outer_number, :neighborhood, :postal_code, :active)
  end
end
