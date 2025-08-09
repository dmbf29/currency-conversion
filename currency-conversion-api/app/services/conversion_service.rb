class ConversionService
  def self.convert(amount:, from:, to:)
    begin
      result = Rates::Cache.call(from: from, to: to)
      converted_amount = (amount * result[:rate]).round(6)

      {
        amount: amount,
        base_currency: from,
        target_currency: to,
        rate_used: result[:rate],
        converted_amount: converted_amount,
        rate_fetched_at: result[:fetched_at]
      }
    rescue StandardError => e
      {
        error: true,
        message: "Failed to fetch exchange rate: #{e.message}"
      }
    end
  end
end
