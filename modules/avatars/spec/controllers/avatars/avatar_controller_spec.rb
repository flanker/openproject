require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../shared_examples")

RSpec.describe Avatars::AvatarController do
  include_context "there are users with and without avatars"
  let(:enabled) { true }

  before do
    allow(OpenProject::Avatars::AvatarManager).to receive(:local_avatars_enabled?).and_return enabled
  end

  describe ":show" do
    let(:redirect_path) { user_avatar_url(target_user.id) }
    let(:action) { get :show, params: { id: target_user.id } }

    context "as anonymous" do
      let(:target_user) { user_with_avatar }
      let(:current_user) { User.anonymous }

      it_behaves_like "an action checked for required login"
    end

    describe "when logged in" do
      let(:user) { create(:user) }

      before do
        login_as user
        action
      end

      context "when avatars enabled" do
        context "when user has avatar" do
          let(:target_user) { user_with_avatar }

          it "renders the send file" do
            expect(response).to have_http_status :ok
          end
        end

        context "when user has no avatar" do
          let(:target_user) { user_without_avatar }

          it "renders 404" do
            expect(response).to have_http_status :not_found
          end
        end
      end

      context "when avatars disabled" do
        let(:enabled) { false }
        let(:target_user) { user_with_avatar }

        it "renders a 404" do
          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
