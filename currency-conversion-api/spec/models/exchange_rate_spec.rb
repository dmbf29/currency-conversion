require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  let(:valid_attributes) do
    {
      base_currency: "USD",
      target_currency: "EUR",
      rate: BigDecimal("0.85"),
      fetched_at: Time.current
    }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      exchange_rate = build(:exchange_rate)
      expect(exchange_rate).to be_valid
    end

    it "requires a base currency" do
      exchange_rate = build(:exchange_rate, base_currency: nil)
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:base_currency]).to include("can't be blank")
    end

    it "requires a target currency" do
      exchange_rate = build(:exchange_rate, target_currency: nil)
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:target_currency]).to include("can't be blank")
    end

    it "requires a rate" do
      exchange_rate = build(:exchange_rate, rate: nil)
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:rate]).to include("can't be blank")
    end

    it "requires a fetched_at timestamp" do
      exchange_rate = build(:exchange_rate, fetched_at: nil)
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:fetched_at]).to include("can't be blank")
    end
  end

  describe "numericality validations" do
    it "validates rate is a number" do
      exchange_rate = build(:exchange_rate, rate: "not a number")
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:rate]).to include("is not a number")
    end

    it "validates rate is greater than 0" do
      exchange_rate = build(:exchange_rate, rate: 0)
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:rate]).to include("must be greater than 0")

      exchange_rate = build(:exchange_rate, rate: -1)
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:rate]).to include("must be greater than 0")
    end
  end

  describe "currency validations" do
    it "must be a 3-letter uppercase code" do
      exchange_rate = build(:exchange_rate, base_currency: "USD")
      expect(exchange_rate).to be_valid
      expect(exchange_rate.base_currency).to eq("USD")
    end

    it "rejects invalid currency codes" do
      invalid_codes = [ "US", "USDD", "123" ]
      invalid_codes.each do |code|
        exchange_rate = build(:exchange_rate, base_currency: code)
        expect(exchange_rate).not_to be_valid
        expect(exchange_rate.errors[:base_currency]).to include("is invalid")
      end
    end

    it "normalizes currency codes to uppercase on save" do
      exchange_rate = build(:exchange_rate, base_currency: "usd")
      exchange_rate.save!
      expect(exchange_rate.reload.base_currency).to eq("USD")
    end

    it "rejects invalid target currency codes" do
      invalid_codes = [ "EU", "EURO", "456" ]
      invalid_codes.each do |code|
        exchange_rate = build(:exchange_rate, target_currency: code)
        expect(exchange_rate).not_to be_valid
        expect(exchange_rate.errors[:target_currency]).to include("is invalid")
      end
    end

    it "normalizes target currency codes to uppercase on save" do
      exchange_rate = build(:exchange_rate, target_currency: "eur")
      exchange_rate.save!
      expect(exchange_rate.reload.target_currency).to eq("EUR")
    end

    it "requires different base and target currencies" do
      exchange_rate = build(:exchange_rate, base_currency: "USD", target_currency: "USD")
      expect(exchange_rate).not_to be_valid
      expect(exchange_rate.errors[:target_currency]).to include("must be different from base_currency")
    end
  end

  describe "edge cases" do
    it "handles very small rates" do
      exchange_rate = build(:exchange_rate, rate: BigDecimal("0.000001"))
      expect(exchange_rate).to be_valid
    end

    it "handles very large rates" do
      exchange_rate = build(:exchange_rate, rate: BigDecimal("999999.99"))
      expect(exchange_rate).to be_valid
    end

    it "handles future timestamps" do
      exchange_rate = build(:exchange_rate, fetched_at: 1.year.from_now)
      expect(exchange_rate).to be_valid
    end

    it "handles past timestamps" do
      exchange_rate = build(:exchange_rate, fetched_at: 1.year.ago)
      expect(exchange_rate).to be_valid
    end
  end

  describe "database persistence" do
    it "can be saved to the database" do
      exchange_rate = build(:exchange_rate)
      expect { exchange_rate.save! }.to change(ExchangeRate, :count).by(1)
    end

    it "can be retrieved from the database" do
      exchange_rate = create(:exchange_rate)
      retrieved = ExchangeRate.find(exchange_rate.id)
      expect(retrieved.base_currency).to eq(exchange_rate.base_currency)
      expect(retrieved.target_currency).to eq(exchange_rate.target_currency)
      expect(retrieved.rate).to eq(exchange_rate.rate)
    end

    it "can be updated" do
      exchange_rate = create(:exchange_rate)
      exchange_rate.update!(rate: BigDecimal("0.90"))
      expect(exchange_rate.reload.rate).to eq(BigDecimal("0.90"))
    end

    it "can be deleted" do
      exchange_rate = create(:exchange_rate)
      expect { exchange_rate.destroy! }.to change(ExchangeRate, :count).by(-1)
    end
  end

  describe "uniqueness constraints" do
    it "enforces unique base_currency and target_currency combination" do
      create(:exchange_rate, base_currency: "USD", target_currency: "EUR")

      duplicate = build(:exchange_rate, base_currency: "USD", target_currency: "EUR")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:base_currency]).to include("has already been taken")
    end

    it "allows different currencies" do
      create(:exchange_rate, base_currency: "USD", target_currency: "EUR")

      different_currencies = build(:exchange_rate, base_currency: "USD", target_currency: "GBP")
      expect(different_currencies).to be_valid
    end

    it "allows same currencies in reverse order" do
      create(:exchange_rate, base_currency: "USD", target_currency: "EUR")

      reverse_order = build(:exchange_rate, base_currency: "EUR", target_currency: "USD")
      expect(reverse_order).to be_valid
    end
  end
end
