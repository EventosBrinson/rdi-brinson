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
  describe 'POST #create' do
    context 'when current user has admin rights' do
      context 'and the right params are present' do
        it 'creates a new document record and saves the file to disk' do
          user = FactoryGirl.create :user, :confirmed, :staff
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token

          expect{ post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: 'tiger.jpg', data: Constants::Images::BASE64_2x2 }}}.to change{ Document.count }.by(1)
          expect(response).to be_success
          expect(assigns(:document).file_file_name).to eq('tiger.jpg')
        end
        it 'returns a json object with the new document' do
          user = FactoryGirl.create :user, :confirmed, :staff
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: 'tiger.jpg', data: Constants::Images::BASE64_2x2 }}

          expect(response).to be_success
          expect(response).to render_template('documents/show.json')
        end
      end
      context 'and the document information is erratic' do
        it 'does not create a new document' do
          user = FactoryGirl.create :user, :confirmed, :staff
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token

          expect{ post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: '', data: Constants::Images::BASE64_2x2 }}}.to_not change{ Document.count }
          expect(response).to be_success
          expect(assigns(:document).errors).to_not be_empty
        end
        it 'returns the document errors json object' do
          user = FactoryGirl.create :user, :confirmed, :staff
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: '', data: Constants::Images::BASE64_2x2 }}

          expect(response.body).to_not be_empty
          expect(assigns(:document).errors).to_not be_empty
        end
      end
    end
    context 'when the user is an average user' do
      context 'and is trying to create a document for a client he owns' do
        it 'creates a new document record and saves the file to disk' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token

          expect{ post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: 'tiger.jpg', data: Constants::Images::BASE64_2x2 }}}.to change{ Document.count }.by(1)
          expect(response).to be_success
          expect(assigns(:document).file_file_name).to eq('tiger.jpg')
        end
        it 'returns a json object with the new document' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client, creator: user

          request.headers[:HTTP_AUTH_TOKEN] = token
          post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: 'tiger.jpg', data: Constants::Images::BASE64_2x2 }}

          expect(response).to be_success
          expect(response).to render_template('documents/show.json')
        end
      end
      context 'and is trying to create a document for a client he does not own' do
        it 'does not create a new document' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token

          expect{ post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: 'tiger.jpg', data: Constants::Images::BASE64_2x2 }}}.to_not change{ Document.count }
        end
        it 'returns forbidden' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          client_to_attach = FactoryGirl.create :client

          request.headers[:HTTP_AUTH_TOKEN] = token
          post :create, params: { document: { title: 'ID Photo', client_id: client_to_attach.id, filename: '', data: Constants::Images::BASE64_2x2 }}

          expect(response).to be_forbidden
        end
      end
    end
  end
  describe 'PATCH #update' do
    context 'when current user has admin rights' do
      context 'and the right params are present' do
        it 'updates the document record' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: 'Funny pic' }}
          
          expect(response).to be_success
          expect(assigns(:document).title).to eq('Funny pic')
        end
        it 'returns a json object with the updated document' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: 'Funny pic' }}
          
          expect(response).to be_success
          expect(response).to render_template('documents/show.json')
        end
      end
      context 'and the document information is erratic' do
        it 'does not update the document' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: '' }}

          previous_title = document.title
          document.reload

          expect(response).to be_success
          expect(document.title).to eq(previous_title)
        end
        it 'returns the document errors json object' do
          user = FactoryGirl.create :user, :confirmed, :admin
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: '' }}

          expect(response).to be_success
          expect(assigns(:document).errors).to_not be_empty
        end
      end
    end
    context 'when the user is an average user' do
      context 'and is trying to update a document of a client he owns' do
        it 'updates the document record' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document, client: FactoryGirl.create(:client, creator: user)

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: 'Funny pic' }}
          
          expect(response).to be_success
          expect(assigns(:document).title).to eq('Funny pic')
        end
        it 'returns a json object with the updated document' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document, client: FactoryGirl.create(:client, creator: user)

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: 'Funny pic' }}
          
          expect(response).to be_success
          expect(response).to render_template('documents/show.json')
        end
      end
      context 'and is trying to update a document of a client he does not own' do
        it 'does not update the document' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: 'Funny pic' }}

          previous_title = document.title
          document.reload

          expect(document.title).to eq(previous_title)
        end
        it 'returns forbidden' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document

          request.headers[:HTTP_AUTH_TOKEN] = token
          patch :update, params: { id: document.id, document: { title: 'Funny pic' }}

          expect(response).to be_forbidden
        end
      end
    end
    context 'the id is not form an actual document' do
      it 'returns not found' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        patch :update, params: { id: 969 }

        expect(response).to be_not_found
      end
    end
  end
  describe 'DELETE #destroy' do
    context 'when current user has admin rights' do
      it 'deletes the document record and remove the file form disk' do
        user = FactoryGirl.create :user, :confirmed, :admin
        token = Sessions::Create.for credential: user.username, password: user.password

        document = FactoryGirl.create :document

        request.headers[:HTTP_AUTH_TOKEN] = token
        expect{ delete :destroy, params: { id: document.id }}.to change(Document, :count).to(0)
        
        expect(response).to be_success
      end
    end
    context 'when the user is an average user' do
      context 'and is trying to delete a document of a client he owns' do
        it 'deletes the document record and remove the file form disk' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document, client: FactoryGirl.create(:client, creator: user)

          request.headers[:HTTP_AUTH_TOKEN] = token
          expect{ delete :destroy, params: { id: document.id }}.to change(Document, :count).to(0)
          
          expect(response).to be_success
        end
      end
      context 'and is trying to delete a document of a client he does not own' do
        it 'does not delete the document and returns forbidden' do
          user = FactoryGirl.create :user, :confirmed
          token = Sessions::Create.for credential: user.username, password: user.password

          document = FactoryGirl.create :document

          request.headers[:HTTP_AUTH_TOKEN] = token
          delete :destroy, params: { id: document.id }

          expect(response).to be_forbidden
        end
      end
    end
    context 'the id is not form an actual document' do
      it 'returns not found' do
        user = FactoryGirl.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        delete :destroy, params: { id: 969 }

        expect(response).to be_not_found
      end
    end
  end
end
