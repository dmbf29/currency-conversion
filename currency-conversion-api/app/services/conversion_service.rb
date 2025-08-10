class ConversionService
  def self.convert(amount:, from:, to:)
    begin
      parsed_amount = BigDecimal(amount.to_s)
      from_code = from.to_s.upcase
      to_code   = to.to_s.upcase

      result = Rates::Cache.call(from: from_code, to: to_code)
      converted_amount = (parsed_amount * result[:rate]).round(6)

      {
        amount: parsed_amount,
        base_currency: from_code,
        target_currency: to_code,
        rate_used: result[:rate],
        converted_amount: converted_amount,
        rate_fetched_at: result[:fetched_at]
      }
    rescue ArgumentError, TypeError
      {
        error: true,
        message: "Amount must be a valid number",
        status: :bad_request
      }
    rescue StandardError => e
      {
        error: true,
        message: "Failed to fetch exchange rate: #{e.message}"
      }
    end
  end
end
