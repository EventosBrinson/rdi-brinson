require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  describe 'GET #show' do
    it 'returns the file related to the document record' do
      user = FactoryGirl.create :user, :confirmed
      token = Sessions::Create.for credential: user.username, password: user.password

      docuemnt_to_retrieve  = FactoryGirl.create :document

      request.headers[:HTTP_AUTH_TOKEN] = token
      get :show, params: { id: docuemnt_to_retrieve.id }

      expect(response).to be_success
      expect(assigns(:document)).to eq(docuemnt_to_retrieve)
      expect(response.body).to_not be_empty
    end

    context 'the id is not form an actual document' do
      it 'returns 404' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :show, params: { id: 969 }

        expect(response).to be_not_found
      end
    end
  end
end
