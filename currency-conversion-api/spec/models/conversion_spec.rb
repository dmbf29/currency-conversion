require 'rails_helper'

RSpec.describe Conversion, type: :model do
  it "requires positive amount" do
    conversion = Conversion.new(
      amount: 0,
      base_currency: "USD",
      target_currency: "EUR",
      rate_used: 1.1,
      converted_amount: 0.0,
      rate_fetched_at: Time.current
    )
    expect(conversion).not_to be_valid
  end
end
