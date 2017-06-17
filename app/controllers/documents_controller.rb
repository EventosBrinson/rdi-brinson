class DocumentsController < ApplicationController
  before_action :authenticate_request

  def show
    authorize! :show, Document
    @document = Document.find_by_id params[:id]

    if @document
      if params[:thumb]
        send_file @document.file.path(:thumb), disposition: 'inline'
      else
        send_file @document.file.path, disposition: 'inline'
      end
    else
      head :not_found
    end
  end

  def create
    @document = Document.new document_params
    @document.set_file_from params: file_params

    authorize! :create, @document

    if @document.save
      render template: 'documents/show.json'
    else
      render json: @document.errors
    end
  end

  def update
    @document = Document.find_by id: params[:id]

    if @document
      @document.assign_attributes document_updateable_params
      authorize! :update, @document

      if @document.save
        render template: 'documents/show.json'
      else
        render json: @document.errors
      end
    else
      head :not_found
    end
  end

  def destroy
    @document = Document.find_by id: params[:id]

    if @document
      authorize! :delete, @document

      @document.destroy

      head :ok
    else
      head :not_found
    end
  end

  private

  def document_params
    params.require(:document).permit(:title, :client_id)
  end

  def document_updateable_params
    params.require(:document).permit(:title)
  end

  def file_params
    params.require(:document).permit(:filename, :data)
  end
end
