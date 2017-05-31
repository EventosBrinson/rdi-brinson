class DocumentsController < ApplicationController
  before_action :authenticate_request

  def show
    @document = Document.find_by_id params[:id]

    if @document
      send_file @document.file.path
    else
      head :not_found
    end
  end
end
