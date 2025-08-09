class ConversionService
  def self.convert(amount:, from:, to:)
    result = Rates::Fetcher.call(from: from, to: to)
    converted_amount = (amount * result[:rate]).round(6)

    {
      amount: amount,
      base_currency: from,
      target_currency: to,
      rate_used: result[:rate],
      converted_amount: converted_amount,
      rate_fetched_at: result[:fetched_at]
    }
  end
end
