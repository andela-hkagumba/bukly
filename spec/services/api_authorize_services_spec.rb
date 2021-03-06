require "rails_helper"

RSpec.describe ApiAuthorizeService do
  let(:user) { create(:user) }

  def auth_headers(user_type)
    {
      "Authorization" => token(user_type)
    }
  end

  def service(headers = {})
    described_class.new(headers)
  end

  describe "Authorize user" do
    it "authorize user using the authorization header" do
      expect(service(auth_headers(user)).authorize[:user]).
        to eql user
    end

    it "raises an error if authorization header missing" do
      expect do
        service.authorize
      end.to raise_error ExceptionHandlers::AccessDeniedError
    end

    it "raises error if token is incorrect" do
      expect do
        service("Authorization" => Faker::Bitcoin.address).authorize
      end.to raise_error ExceptionHandlers::NotAuthenticatedError
    end

    it "raises error if user non-existent" do
      expect do
        service(auth_headers(build(:user))).authorize
      end.to raise_error ExceptionHandlers::UserNotFoundError
    end

    it "raises an error when token is expired" do
      Timecop.travel(2.month.from_now)

      expect do
        service(auth_headers(user)).authorize
      end.to raise_error ExceptionHandlers::ExpiredSignatureError

      Timecop.return
    end
  end
end
