class RentsController < ApplicationController
  before_action :authenticate_request
  helper FormattedTimeHelper

  def index
    authorize! :index, Place

    if params[:user_id]
      @user = User.find_by id: params[:user_id]

      if @user
        authorize! :show, @user
        @rents = get_rents

        render template: 'rents/index.json'
      else
        head :not_found
      end
    elsif params[:client_id]
      @client = Client.find_by id: params[:client_id]

      if @client
        authorize! :show, @client
        @rents = get_rents

        render template: 'rents/index.json'
      else
        head :not_found
      end
    elsif params[:place_id]
      @place = Place.find_by id: params[:place_id]

      if @place
        authorize! :show, @place
        @rents = get_rents

        render template: 'rents/index.json'
      else
        head :not_found
      end
    else
      @rents = get_rents
      render template: 'rents/index.json'
    end
  end

  def show
    @rent = Rent.find_by id: params[:id]

    if @rent
      authorize! :show, @rent

      if params[:format] == 'pdf'
        pdf = WickedPdf.new.pdf_from_string(render_to_string('rents/show.pdf', layout: 'layouts/pdf.html'),
                                                              page_size: 'Letter',
                                                              title: 'Documento',
                                                              dpi: '96',
                                                              disable_smart_shrinking: true)

        send_data(pdf, filename: "renta_##{@rent.order_number}_#{@rent.client.firstname.parameterize.underscore}.pdf", type: 'application/pdf', disposition: 'inline')
      else
        render template: 'rents/show.json'
      end
    else
      head :not_found
    end
  end

  def create
    @rent = Rent.new rent_params
    @rent.creator = current_user

    if @rent.validate
      authorize! :create, @rent

      @rent.save

      render template: 'rents/show.json'
    else
      render json: @rent.errors
    end
  end

  def update
    @rent = Rent.find_by id: params[:id]

    if @rent
      @rent.assign_attributes rent_updateable_params
      authorize! :update, @rent

      if @rent.save
        render template: 'rents/show.json'
      else
        render json: @rent.errors
      end
    else
      head :not_found
    end
  end

  private

  def get_rents
    if params[:search] || params[:ordered] || params[:paginated] || params[:filter_by_time]
      if params[:user_id]
        @user.rents.filter(params.slice(:search, :ordered, :paginated, :filter_by_time))
      elsif params[:client_id]
        @client.rents.filter(params.slice(:search, :ordered, :paginated, :filter_by_time))
      elsif params[:place_id]
        @place.rents.filter(params.slice(:search, :ordered, :paginated, :filter_by_time))
      elsif current_user.admin? || current_user.staff? and params[:all]
        Rent.filter(params.slice(:search, :ordered, :paginated, :filter_by_time))
      else
        current_user.rents.filter(params.slice(:search, :ordered, :paginated, :filter_by_time))
      end
    else
      if params[:user_id]
        @user.rents.ordered(id: :desc)
      elsif params[:client_id]
        @client.rents.ordered(id: :desc)
      elsif params[:place_id]
        @place.rents.ordered(id: :desc)
      elsif current_user.admin? || current_user.staff? and params[:all]
        Rent.all.ordered(id: :desc)
      else
        current_user.rents.ordered(id: :desc)
      end
    end
  end

  def rent_params
    params.require(:rent).permit(:delivery_time, :pick_up_time, :product, :price, :discount, :additional_charges, :additional_charges_notes, :client_id, :place_id)
  end

  def rent_updateable_params
    params.require(:rent).permit(:delivery_time, :pick_up_time, :product, :price, :discount, :additional_charges, :additional_charges_notes, :status)
  end
end
