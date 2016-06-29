require "rails_helper"

RSpec.describe Api::V1::BucketsController, type: :controller do
  let(:bucket) { create(:bucket) }
  let(:headers) { { ACCEPT: "application/vnd.bukly+json; version=1" } }
  let(:valid_attributes) { attributes_for(:bucket) }
  let(:invalid_attributes) { attributes_for(:invalid_bucket) }

  describe "Get all buckets" do
    context "when all buckets are retrieved" do
      before { create_list(:bucket, 3) }

      it "returns all buckets" do
        allow(request).to receive(:headers).and_return(headers)
        get :index

        expect(response).to be_success
        expect(json.length).to eql 3
      end
    end

    context "when there are no bucketlists" do
      it "returns an error message" do
        allow(request).to receive(:headers).and_return(headers)
        get :index

        expect(response).to be_success
        expect(json.fetch("errors")).
          to eql ExceptionMessages::Messages.no_resources("bucketlists")
      end
    end
  end

  describe "Show a bucket" do
    let!(:show_bucket) { create(:bucket) }

    context "when a user requests for a bucket" do
      it "returns the requested bucket" do
        allow(request).to receive(:headers).and_return(headers)
        get :show, id: show_bucket.id

        expect(response).to be_success
        expect(json).to match_response_schema("bucket")
        expect(json.fetch("name")).to eql show_bucket.name
      end
    end

    context "when a non-existent bucket is requested" do
      it "returns an not found error" do
        allow(request).to receive(:headers).and_return(headers)
        get :show, id: show_bucket.name

        expect(response).to be_not_found
        expect(json.fetch("errors")).
          to eql ExceptionMessages::Messages.no_resource("Bucket")
      end
    end
  end

  describe "Create a bucket" do
    context "when a bucketlist is created with valid attributes" do
      it "creates the bucket successfully" do
        allow(request).to receive(:headers).and_return(headers)
        expect do
          post :create, valid_attributes
        end.to change{ Bucket.count }.by(1)

        expect(response).to be_created
        expect(json).to match_response_schema("bucket")
        expect(json.fetch("name")).to eql valid_attributes[:name]
      end
    end

    context "when a bucketlist is created with invalid attributes" do
      it "should return a validation error" do
        allow(request).to receive(:headers).and_return(headers)
        post :create, invalid_attributes

        expect(response).to have_http_status 422
        expect(json.fetch("errors")).to include "Name can't be blank"
      end
    end
  end

  describe "Update a bucket" do
    let!(:update_bucket) { create(:bucket) }

    context "when a bucket is updated using valid attributes" do
      it "updates the bucket successfully" do
        allow(request).to receive(:headers).and_return(headers)
        put :update, id: update_bucket.id, name: valid_attributes[:name]

        expect(response).to have_http_status 204
        expect(Bucket.find(update_bucket.id).name).
          to eql valid_attributes[:name]
      end
    end

    context "when a bucket is updated using invalid attributes" do
      it "returns a validation error" do
        allow(request).to receive(:headers).and_return(headers)
        put :update, id: update_bucket.id, name: invalid_attributes[:name]

        expect(response).to have_http_status 422
        expect(json.fetch("errors")).to include "Name can't be blank"
      end
    end

    context "when the bucket doesn't exist" do
      it "returns a not found error" do
        allow(request).to receive(:headers).and_return(headers)
        put :update, id: update_bucket.name, name: valid_attributes[:name]

        expect(response).to be_not_found
        expect(json.fetch("errors")).
          to eql ExceptionMessages::Messages.no_resource("Bucket")
      end
    end
  end

  describe "Delete bucket" do
    let!(:delete_bucket) { create(:bucket) }

    context "when a bucket exists" do
      it "deletes successfully" do
        allow(request).to receive(:headers).and_return(headers)
        expect do
          delete :destroy, id: delete_bucket.id
        end.to change{ Bucket.count }.by(-1)

        expect(response).to have_http_status 204
      end
    end

    context "when a bucket doesn't exist" do
      it "returns a not found error" do
        allow(request).to receive(:headers).and_return(headers)
        delete :destroy, id: delete_bucket.name

        expect(response).to be_not_found
        expect(json.fetch("errors")).
          to eql ExceptionMessages::Messages.no_resource("Bucket")
      end
    end
  end
end