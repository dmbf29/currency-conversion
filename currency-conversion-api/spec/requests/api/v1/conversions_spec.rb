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

      it "returns numeric values as numbers, not strings" do
        post "/api/v1/convert", params: valid_params

        json_response = JSON.parse(response.body)
        expect(json_response["amount"]).to be_a(Numeric)
        expect(json_response["converted_amount"]).to be_a(Numeric)
        expect(json_response["rate_used"]).to be_a(Numeric)
        expect(json_response["id"]).to be_a(Integer)
      end

      it "returns the correct data structure" do
        post "/api/v1/convert", params: valid_params

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("id")
        expect(json_response).to have_key("amount")
        expect(json_response).to have_key("base_currency")
        expect(json_response).to have_key("target_currency")
        expect(json_response).to have_key("converted_amount")
        expect(json_response).to have_key("rate_used")
        expect(json_response).to have_key("rate_timestamp")
        expect(json_response).to have_key("created_at")
      end

      it "calls ConversionService.convert with correct parameters" do
        expect(ConversionService).to receive(:convert).with(
          amount: "100.50",
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

    context "with malformed requests (400 errors)" do
      it "returns 400 when amount is missing" do
        post "/api/v1/convert", params: { from: "USD", to: "EUR" }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 400 when from is missing" do
        post "/api/v1/convert", params: { amount: "100", to: "EUR" }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 400 when to is missing" do
        post "/api/v1/convert", params: { amount: "100", from: "USD" }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 400 when all parameters are missing" do
        post "/api/v1/convert", params: {}
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 400 when amount is empty string" do
        post "/api/v1/convert", params: { amount: "", from: "USD", to: "EUR" }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 400 when from is empty string" do
        post "/api/v1/convert", params: { amount: "100", from: "", to: "EUR" }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 400 when to is empty string" do
        post "/api/v1/convert", params: { amount: "100", from: "USD", to: "" }
        expect(response).to have_http_status(:bad_request)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end
    end

    context "with invalid business rules (422 errors)" do
      it "returns 422 when amount is zero" do
        post "/api/v1/convert", params: { amount: "0", from: "USD", to: "EUR" }
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 422 when amount is not a valid number" do
        post "/api/v1/convert", params: { amount: "not_a_number", from: "USD", to: "EUR" }
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 422 when amount is negative" do
        post "/api/v1/convert", params: { amount: "-100", from: "USD", to: "EUR" }
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 422 when currency codes are not 3 characters" do
        post "/api/v1/convert", params: { amount: "100", from: "US", to: "EUR" }
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 422 when currency codes are identical" do
        post "/api/v1/convert", params: { amount: "100", from: "USD", to: "USD" }
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end

      it "returns 422 when currency codes contain numbers or special characters" do
        post "/api/v1/convert", params: { amount: "100", from: "US1", to: "EUR" }
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to be_present
      end
    end

    context "when ConversionService fails" do
      it "returns 422 with error message when service returns network error" do
        allow(ConversionService).to receive(:convert).and_return({
          error: true,
          message: "Failed to fetch exchange rate: Network timeout"
        })

        post "/api/v1/convert", params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Failed to fetch exchange rate: Network timeout")
      end

      it "returns 422 when Frankfurter API returns 404" do
        allow(ConversionService).to receive(:convert).and_return({
          error: true,
          message: "Failed to fetch exchange rate: Frankfurter API returned 404"
        })

        post "/api/v1/convert", params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Failed to fetch exchange rate: Frankfurter API returned 404")
      end

      it "returns 422 when currency pair is not supported" do
        allow(ConversionService).to receive(:convert).and_return({
          error: true,
          message: "Currency pair USD to XYZ not supported by Frankfurter"
        })

        post "/api/v1/convert", params: { amount: "100", from: "USD", to: "XYZ" }
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Currency pair USD to XYZ not supported by Frankfurter")
      end

      it "returns 422 when Frankfurter API is unavailable" do
        allow(ConversionService).to receive(:convert).and_return({
          error: true,
          message: "Failed to fetch exchange rate: Service unavailable"
        })

        post "/api/v1/convert", params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Failed to fetch exchange rate: Service unavailable")
      end
    end

    context "when model validation fails" do
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

      it "returns 422 when conversion fails to save due to validation errors" do
        # Mock save to fail with validation errors
        allow_any_instance_of(Conversion).to receive(:save).and_return(false)
        allow_any_instance_of(Conversion).to receive(:errors).and_return(
          double(full_messages: [ "Base currency must be exactly 3 characters" ])
        )

        post "/api/v1/convert", params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Base currency must be exactly 3 characters")
      end

      it "returns 422 when conversion fails due to database constraint" do
        allow_any_instance_of(Conversion).to receive(:save).and_return(false)
        allow_any_instance_of(Conversion).to receive(:errors).and_return(
          double(full_messages: [ "Rate used must be greater than 0" ])
        )

        post "/api/v1/convert", params: valid_params
        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("Rate used must be greater than 0")
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

      it "handles numeric amount parameters (Float)" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("1.40"),
          base_currency: "USD",
          target_currency: "EUR",
          rate_used: BigDecimal("0.85"),
          converted_amount: BigDecimal("1.19"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: 1.40, from: "USD", to: "EUR" }
        expect(response).to have_http_status(:created)
      end

      it "handles numeric amount parameters (Integer)" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("100"),
          base_currency: "USD",
          target_currency: "EUR",
          rate_used: BigDecimal("0.85"),
          converted_amount: BigDecimal("85"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: 100, from: "USD", to: "EUR" }
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

      it "handles currency pairs with high exchange rates (like USD to JPY)" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("1.00"),
          base_currency: "USD",
          target_currency: "JPY",
          rate_used: BigDecimal("150.25"),
          converted_amount: BigDecimal("150.25"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: "1.00", from: "USD", to: "JPY" }
        expect(response).to have_http_status(:created)
      end

      it "handles currency pairs with very small exchange rates" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: BigDecimal("1000.00"),
          base_currency: "JPY",
          target_currency: "USD",
          rate_used: BigDecimal("0.006658"),
          converted_amount: BigDecimal("6.658"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: "1000.00", from: "JPY", to: "USD" }
        expect(response).to have_http_status(:created)
      end
    end

    context "parameter type handling" do
      it "converts string amount to BigDecimal for service call" do
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
          amount: "100.50",
          from: "USD",
          to: "EUR"
        )
      end

      it "passes numeric string amount to service unchanged" do
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
          amount: "100",
          from: "USD",
          to: "EUR"
        )
      end

      it "passes float amount to service which handles conversion" do
        allow(ConversionService).to receive(:convert).and_return({
          amount: 1.4,
          base_currency: "USD",
          target_currency: "EUR",
          rate_used: BigDecimal("0.85"),
          converted_amount: BigDecimal("1.19"),
          rate_fetched_at: Time.current
        })

        post "/api/v1/convert", params: { amount: 1.4, from: "USD", to: "EUR" }

        expect(ConversionService).to have_received(:convert).with(
          amount: "1.4",
          from: "USD",
          to: "EUR"
        )
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

    it "returns numeric values as numbers, not strings" do
      get "/api/v1/conversions"
      json_response = JSON.parse(response.body)

      conversion_data = json_response.first
      expect(conversion_data["id"]).to be_a(Integer)
      expect(conversion_data["amount"]).to be_a(Numeric)
      expect(conversion_data["converted_amount"]).to be_a(Numeric)
      expect(conversion_data["rate_used"]).to be_a(Numeric)
      expect(conversion_data["base_currency"]).to be_a(String)
      expect(conversion_data["target_currency"]).to be_a(String)
    end

    it "returns timestamps in ISO8601 format" do
      get "/api/v1/conversions"
      json_response = JSON.parse(response.body)

      conversion_data = json_response.first
      expect(conversion_data["rate_timestamp"]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      expect(conversion_data["created_at"]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
    end

    context "with many conversions" do
      before do
        create_list(:conversion, 25)
      end

      it "returns only recent conversions (no more than 10)" do
        get "/api/v1/conversions"
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to be <= 10
      end

      it "maintains proper ordering with many conversions" do
        get "/api/v1/conversions"
        json_response = JSON.parse(response.body)

        created_at_times = json_response.first(5).map { |c| Time.parse(c["created_at"]) }
        expect(created_at_times).to eq(created_at_times.sort.reverse)
      end
    end
  end
end
