require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    before_action :authenticate_request

    def index
      head :ok
    end
  end

  describe "#authenticate_request" do
    context 'when a vaild token is present' do
      it "allows controllers actions to continue and sets the current session" do
        user = FactoryBot.create :user, :confirmed
        token = Sessions::Create.for credential: user.username, password: user.password

        request.headers[:HTTP_AUTH_TOKEN] = token
        get :index

        expect(assigns(:current_user)).to eq user
        expect(response).to be_successful
      end
    end

    context 'when an erratic token is present' do
      it "denies controllers actions to continue" do
        user = FactoryBot.create :user
        token = 'erraic token'

        request.headers[:HTTP_ACCESS_TOKEN] = 'erratic_token'
        get :index

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
