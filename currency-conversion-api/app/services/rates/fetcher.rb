require "net/http"

module Rates
  class Fetcher
    BASE_URL = "https://api.frankfurter.app"

    # Returns { rate: BigDecimal, fetched_at: Time }
    def self.call(from:, to:)
      url = URI("#{BASE_URL}/latest?from=#{from}&to=#{to}")
      res = Net::HTTP.get_response(url)
      raise "Frankfurter error: #{res.code}" unless res.is_a?(Net::HTTPSuccess)
      p data = JSON.parse(res.body)
      rate = data.dig("rates", to)
      date = data["date"]
      raise "Rate missing" unless rate && date
      {
        rate: BigDecimal(rate.to_s),
        fetched_at: Time.parse("#{date} 00:00:00")
      }
    end
  end
end
