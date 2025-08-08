require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  it "validates currencies and rate" do
    exchange_rate = ExchangeRate.new(base_currency: "usd", target_currency: "EUR", rate: 1.2345, fetched_at: Time.current)
    expect(exchange_rate).to be_valid
    expect(exchange_rate.base_currency).to eq("USD")
  end

  it "rejects same currencies" do
    exchange_rate = ExchangeRate.new(base_currency: "USD", target_currency: "USD", rate: 1, fetched_at: Time.current)
    expect(exchange_rate).not_to be_valid
  end
end
