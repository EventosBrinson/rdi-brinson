class DocumentsController < ApplicationController
  before_action :authenticate_request

  def show
    authorize! :show, Document
    @document = Document.find_by_id params[:id]

    if @document
      send_file @document.file.path, disposition: 'inline'
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
    @document = Document.find_by_id params[:id]
    authorize! :update, @document

    if @document and @document.update document_updatable_params
      render template: 'documents/show.json'
    else
      render json: @document.errors
    end
  end

  def destroy
    @document = Document.find_by_id params[:id]
    authorize! :delete, @document

    if @document and @document.destroy
      head :ok
    else
      render json: @document.errors
    end
  end

  private

  def document_params
    params.require(:document).permit(:title, :client_id)
  end

  def document_updatable_params
    params.require(:document).permit(:title)
  end

  def file_params
    params.require(:document).permit(:filename, :data)
  end
end
