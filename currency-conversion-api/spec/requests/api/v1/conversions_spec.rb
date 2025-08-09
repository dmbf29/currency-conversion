require 'rails_helper'

RSpec.describe "Api::V1::Conversions", type: :request do
  let(:valid_params) do
    { amount: "100.50", from: "USD", to: "EUR" }
  end

  describe "POST /api/v1/convert" do
    context "with valid parameters" do
      before do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("100.50"),
          base_currency: "USD",
          target_currency: "EUR",
          rate_used: BigDecimal("0.85"),
          converted_amount: BigDecimal("85.425"),
          rate_fetched_at: Time.current
        })
      end

      it "creates a new conversion" do
        expect {
          post "/api/v1/convert", params: valid_params
        }.to change(Conversion, :count).by(1)
      end

      it "returns status 201 (created)" do
        post "/api/v1/convert", params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "returns the conversion data in JSON format" do
        post "/api/v1/convert", params: valid_params
        expect(response.content_type).to include("application/json")
      end

      it "calls ConversionService.convert with correct parameters" do
        expect(ConversionService).to receive(:convert).with(
          amount: BigDecimal("100.50"),
          from: "USD",
          to: "EUR"
        )
        post "/api/v1/convert", params: valid_params
      end

      it "saves the conversion with correct attributes" do
        post "/api/v1/convert", params: valid_params
        conversion = Conversion.last

        expect(conversion.amount).to eq(BigDecimal("100.50"))
        expect(conversion.base_currency).to eq("USD")
        expect(conversion.target_currency).to eq("EUR")
        expect(conversion.rate_used).to eq(BigDecimal("0.85"))
        expect(conversion.converted_amount).to eq(BigDecimal("85.425"))
        expect(conversion.rate_fetched_at).to be_present
      end
    end

    context "with edge case parameters" do
      it "handles very small amounts" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("0.01"),
          base_currency: "USD",
          target_currency: "EUR",
          rate_used: BigDecimal("0.85"),
          converted_amount: BigDecimal("0.0085"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: "0.01", from: "USD", to: "EUR" }
        expect(response).to have_http_status(:created)
      end

      it "handles very large amounts" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("1000000"),
          base_currency: "USD",
          target_currency: "EUR",
          rate_used: BigDecimal("0.85"),
          converted_amount: BigDecimal("850000"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: "1000000", from: "USD", to: "EUR" }
        expect(response).to have_http_status(:created)
      end

      it "handles decimal amounts with many places" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("123.456789"),
          base_currency: "USD",
          target_currency: "EUR",
          rate_used: BigDecimal("0.85"),
          converted_amount: BigDecimal("104.93827165"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: "123.456789", from: "USD", to: "EUR" }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/v1/conversions" do
    let!(:conversion1) { create(:conversion, created_at: 2.days.ago) }
    let!(:conversion2) { create(:conversion, created_at: 1.day.ago) }
    let!(:conversion3) { create(:conversion, created_at: Time.current) }

    it "returns status 200 (ok)" do
      get "/api/v1/conversions"
      expect(response).to have_http_status(:ok)
    end

    it "returns the conversions in JSON format" do
      get "/api/v1/conversions"
      expect(response.content_type).to include("application/json")
    end

    it "returns conversions ordered by created_at descending (newest first)" do
      get "/api/v1/conversions"

      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(3)

      # Check order (newest first)
      expect(json_response[0]["id"]).to eq(conversion3.id)
      expect(json_response[1]["id"]).to eq(conversion2.id)
      expect(json_response[2]["id"]).to eq(conversion1.id)
    end

    it "returns empty array when no conversions exist" do
      Conversion.destroy_all

      get "/api/v1/conversions"
      json_response = JSON.parse(response.body)
      expect(json_response).to eq([])
    end

    it "includes all required conversion attributes" do
      get "/api/v1/conversions"
      json_response = JSON.parse(response.body)

      conversion_data = json_response.first
      expect(conversion_data).to have_key("id")
      expect(conversion_data).to have_key("amount")
      expect(conversion_data).to have_key("base_currency")
      expect(conversion_data).to have_key("target_currency")
      expect(conversion_data).to have_key("converted_amount")
      expect(conversion_data).to have_key("rate_used")
      expect(conversion_data).to have_key("rate_timestamp")
      expect(conversion_data).to have_key("created_at")
    end
  end

  describe "parameter handling" do
    it "converts amount to BigDecimal" do
      allow(ConversionService).to receive(:convert).and_return({
        amount: BigDecimal("100.50"),
        base_currency: "USD",
        target_currency: "EUR",
        rate_used: BigDecimal("0.85"),
        converted_amount: BigDecimal("85.425"),
        rate_fetched_at: Time.current
      })

      post "/api/v1/convert", params: { amount: "100.50", from: "USD", to: "EUR" }

      expect(ConversionService).to have_received(:convert).with(
        amount: BigDecimal("100.50"),
        from: "USD",
        to: "EUR"
      )
    end

    it "handles integer amounts" do
      allow(ConversionService).to receive(:convert).and_return({
        amount: BigDecimal("100"),
        base_currency: "USD",
        target_currency: "EUR",
        rate_used: BigDecimal("0.85"),
        converted_amount: BigDecimal("85"),
        rate_fetched_at: Time.current
      })

      post "/api/v1/convert", params: { amount: "100", from: "USD", to: "EUR" }

      expect(ConversionService).to have_received(:convert).with(
        amount: BigDecimal("100"),
        from: "USD",
        to: "EUR"
      )
    end
  end
end
