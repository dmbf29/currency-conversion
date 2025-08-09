require 'rails_helper'

RSpec.describe Conversion, type: :model do
  let(:valid_attributes) do
    {
      amount: BigDecimal("100.0"),
      base_currency: "USD",
      target_currency: "EUR",
      rate_used: BigDecimal("0.85"),
      converted_amount: BigDecimal("85.0"),
      rate_fetched_at: Time.current
    }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      conversion = build(:conversion)
      expect(conversion).to be_valid
    end

    it "requires an amount" do
      conversion = build(:conversion, amount: nil)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:amount]).to include("can't be blank")
    end

    it "requires a base currency" do
      conversion = build(:conversion, base_currency: nil)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:base_currency]).to include("can't be blank")
    end

    it "requires a target currency" do
      conversion = build(:conversion, target_currency: nil)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:target_currency]).to include("can't be blank")
    end

    it "requires a rate used" do
      conversion = build(:conversion, rate_used: nil)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:rate_used]).to include("can't be blank")
    end

    it "requires a converted amount" do
      conversion = build(:conversion, converted_amount: nil)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:converted_amount]).to include("can't be blank")
    end

    it "requires a rate fetched at timestamp" do
      conversion = build(:conversion, rate_fetched_at: nil)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:rate_fetched_at]).to include("can't be blank")
    end
  end

  describe "numericality validations" do
    it "validates amount is a number" do
      conversion = build(:conversion, amount: "not a number")
      expect(conversion).not_to be_valid
      expect(conversion.errors[:amount]).to include("is not a number")
    end

    it "validates rate_used is a number" do
      conversion = build(:conversion, rate_used: "not a number")
      expect(conversion).not_to be_valid
      expect(conversion.errors[:rate_used]).to include("is not a number")
    end

    it "validates converted_amount is a number" do
      conversion = build(:conversion, converted_amount: "not a number")
      expect(conversion).not_to be_valid
      expect(conversion.errors[:converted_amount]).to include("is not a number")
    end

    it "validates amount is greater than 0" do
      conversion = build(:conversion, amount: 0)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:amount]).to include("must be greater than 0")

      conversion = build(:conversion, amount: -1)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:amount]).to include("must be greater than 0")
    end

    it "validates rate_used is greater than 0" do
      conversion = build(:conversion, rate_used: 0)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:rate_used]).to include("must be greater than 0")

      conversion = build(:conversion, rate_used: -1)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:rate_used]).to include("must be greater than 0")
    end

    it "validates converted_amount is greater than 0" do
      conversion = build(:conversion, converted_amount: 0)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:converted_amount]).to include("must be greater than 0")

      conversion = build(:conversion, converted_amount: -1)
      expect(conversion).not_to be_valid
      expect(conversion.errors[:converted_amount]).to include("must be greater than 0")
    end
  end

  describe "currency validations" do
    it "must be a 3-letter uppercase code" do
      conversion = build(:conversion, base_currency: "USD")
      expect(conversion).to be_valid
      expect(conversion.base_currency).to eq("USD")
    end

    it "rejects invalid currency codes" do
      invalid_codes = [ "US", "USDD", "123" ]
      invalid_codes.each do |code|
        conversion = build(:conversion, base_currency: code)
        expect(conversion).not_to be_valid
        expect(conversion.errors[:base_currency]).to include("is invalid")
      end
    end

    it "normalizes currency codes to uppercase on save" do
      conversion = build(:conversion, base_currency: "usd")
      conversion.save!
      expect(conversion.reload.base_currency).to eq("USD")
    end

    it "rejects invalid target currency codes" do
      invalid_codes = [ "EU", "EURO", "456" ]
      invalid_codes.each do |code|
        conversion = build(:conversion, target_currency: code)
        expect(conversion).not_to be_valid
        expect(conversion.errors[:target_currency]).to include("is invalid")
      end
    end

    it "normalizes target currency codes to uppercase on save" do
      conversion = build(:conversion, target_currency: "eur")
      conversion.save!
      expect(conversion.reload.target_currency).to eq("EUR")
    end

    it "requires different base and target currencies" do
      conversion = build(:conversion, base_currency: "USD", target_currency: "USD")
      expect(conversion).not_to be_valid
      expect(conversion.errors[:target_currency]).to include("must be different from base_currency")
    end
  end

  describe "edge cases" do
    it "handles very small amounts" do
      conversion = build(:conversion, amount: BigDecimal("0.000001"))
      expect(conversion).to be_valid
    end

    it "handles very large amounts" do
      conversion = build(:conversion, amount: BigDecimal("999999999.99"))
      expect(conversion).to be_valid
    end

    it "handles very small rates" do
      conversion = build(:conversion, rate_used: BigDecimal("0.000001"))
      expect(conversion).to be_valid
    end

    it "handles very large rates" do
      conversion = build(:conversion, rate_used: BigDecimal("999999.99"))
      expect(conversion).to be_valid
    end

    it "handles very small converted amounts" do
      conversion = build(:conversion, converted_amount: BigDecimal("0.000001"))
      expect(conversion).to be_valid
    end

    it "handles very large converted amounts" do
      conversion = build(:conversion, converted_amount: BigDecimal("999999999.99"))
      expect(conversion).to be_valid
    end
  end

  describe "database persistence" do
    it "can be saved to the database" do
      conversion = build(:conversion)
      expect { conversion.save! }.to change(Conversion, :count).by(1)
    end

    it "can be retrieved from the database" do
      conversion = create(:conversion)
      retrieved = Conversion.find(conversion.id)
      expect(retrieved.amount).to eq(conversion.amount)
      expect(retrieved.base_currency).to eq(conversion.base_currency)
      expect(retrieved.target_currency).to eq(conversion.target_currency)
    end

    it "can be updated" do
      conversion = create(:conversion)
      conversion.update!(amount: BigDecimal("200.0"))
      expect(conversion.reload.amount).to eq(BigDecimal("200.0"))
    end

    it "can be deleted" do
      conversion = create(:conversion)
      expect { conversion.destroy! }.to change(Conversion, :count).by(-1)
    end
  end

  describe "factory variations" do
    it "creates different currency pairs correctly" do
      usd_jpy = create(:conversion_usd_to_jpy)
      expect(usd_jpy.base_currency).to eq("USD")
      expect(usd_jpy.target_currency).to eq("JPY")
      expect(usd_jpy.rate_used).to eq(BigDecimal("110.50"))

      eur_gbp = create(:conversion_eur_to_gbp)
      expect(eur_gbp.base_currency).to eq("EUR")
      expect(eur_gbp.target_currency).to eq("GBP")
      expect(eur_gbp.rate_used).to eq(BigDecimal("0.86"))
    end
  end
end
