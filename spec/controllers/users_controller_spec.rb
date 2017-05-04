require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before { ActionMailer::Base.deliveries = [] }

  describe 'GET #Index' do
    context 'when current user has admin rights' do
      it 'returns the lists of users' do

      end

      context 'when the search param is present' do
        it 'it returns a list of users that match the query' do
          
        end
      end

      context 'when the order param is present' do
        it 'it returns a list of users ordered by a field name' do
          
        end

        context 'but is erratic' do
          it 'it returns a list of users ordered by the default' do
            
          end
        end
      end
    end

    context 'when the current user does not has admin rights' do
      it 'returns forbiden' do

      end
    end
  end

  describe 'POST #create' do
    context 'when current user has admin rights' do
      context 'and a role under admin/staff is present' do
        context 'and the right user information is present' do
          it 'creates a new user sends the invitation email' do

          end

          it 'returns a json object with the new user' do
          end
        end

        context 'when the user information is erratic' do
          it 'does not create a new user' do

          end
          it 'returns the user errors json object' do

          end
        end
      end
    end

    context 'when current user is a main user' do
      context 'and an admin/staff role is present' do
        it 'creates a new user sends the invitation email' do

        end

        it 'returns a json object with the new user' do

        end
      end
    end

    context 'when current user does not has admin rights nor is a main user' do
      it 'returns forbiden and nothing else happens' do

      end
    end
  end

  describe 'PATCH #Update' do
    context 'when the current user is changing its own information' do
      context 'and the right information is present' do
        it 'updates the user editable fields' do

        end

        it 'returns the updated user json object' do
          
        end
      end
      context 'and erratic information is present' do
        it 'does not update the user' do

        end

        it 'returns the user errors json object' do
          
        end
      end
    end

    context 'when the current user is changing an average user information' do
      context 'and the current user is an admin/staff user' do
        it 'changes the other user editable fields' do
          
        end

        it 'returns the updated user json object' do
          
        end
      end
      context 'and the current user is an average user' do
        it 'returns forbiden and nothing else happens' do
          
        end
      end
    end

    context 'when the current user is changing an admin/staff user information' do
      context 'and the current user is a main user' do
        it 'changes the other user editable fields' do
          
        end

        it 'returns the updated user json object' do
          
        end
      end
      context 'and the current user is not a main user' do
        it 'returns forbiden and nothing else happens' do
          
        end
      end
    end

    context 'when email param is present' do
      context 'and the current user is changing its own email' do
        it 'changes the current user email, opens a confirmation and sends the reconfirmation email' do
            
        end

        it 'returns the updated user json object' do
          
        end
      end
      context 'and the current user is changing an average user email' do
        context 'and the current user is admin/staff user' do
          it 'changes the other user email, opens a confirmation and sends the reconfirmation email' do
            
          end

          it 'returns the updated user json object' do
          
          end
        end
        context 'and the current user is an average user' do
          it 'returns forbiden and nothing else happens' do
            
          end
        end
      end
      context 'and the current user is changing an admin/staff user email' do
        context 'and the current user is a main user' do
          it 'changes the other user email, opens a confirmation and sends the reconfirmation email' do
            
          end

          it 'returns the updated user json object' do
          
          end
        end
        context 'and the current user is not a main user' do
          it 'returns forbiden and nothing else happens' do
            
          end
        end
      end
    end

    context 'the role param is present' do
      context 'and the current user is changing its own role' do
        it 'returns forbiden and nothing else happens' do
            
        end
      end
      context 'and the current user is changing an average user role' do
        context 'and the current user is admin/staff user' do
          context 'and the new role is under admin/staff' do
            it 'changes the other user role' do
            
            end

            it 'returns the updated user json object' do
              
            end
          end
        end
        context 'and the current user is an average user' do
          it 'returns forbiden and nothing else happens' do
            
          end
        end
      end
      context 'and the current user is changing an admin/staff user role' do
        context 'and the current user is a main user' do
          it 'changes the other user role' do
            
          end

          it 'returns the updated user json object' do
            
          end
        end
        context 'and the current user is not a main user' do
          it 'returns forbiden and nothing else happens' do
            
          end
        end
      end
    end

    context 'the password param is present' do
      context 'and the current user is changing its own password' do
        context 'and the right current password is present' do
          it 'changes the current user password and sends the password changed email' do
            
          end

          it 'returns the updated user json object' do
          
          end
        end
        context 'and the wrong current password is present' do
          it 'returns forbiden and nothing else happens' do
            
          end
        end
      end
      context 'and the current user is changing an average user password' do
        context 'and the current user is admin/staff user' do
          it 'changes the other user password and sends the password changed email' do
            
          end

          it 'returns the updated user json object' do
          
          end
        end
        context 'and the current user is an average user' do
          it 'returns forbiden and nothing else happens' do
            
          end
        end
      end
      context 'and the current user is changing an an admin/staff user password' do
        context 'and the current user is a main user' do
          it 'changes the other user password and sends the password changed email' do
            
          end

          it 'returns the updated user json object' do
          
          end
        end
        context 'and the current user is not main user' do
          it 'returns forbiden and nothing else happens' do
            
          end
        end
      end
    end
  end
end
