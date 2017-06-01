class DocumentsController < ApplicationController
  before_action :authenticate_request

  def show
    authorize! :show, Document
    @document = Document.find_by_id params[:id]

    if @document
      send_file @document.file.path
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

  private

  def document_params
    params.require(:document).permit(:title, :client_id)
  end

  def file_params
    params.require(:document).permit(:filename, :data)
  end
end
