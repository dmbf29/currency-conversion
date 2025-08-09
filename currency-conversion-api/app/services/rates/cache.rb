module Rates
  class Cache
    TTL = 1.hour

    def self.call(from:, to:)
      rate_record = ExchangeRate.find_by(base_currency: from.upcase, target_currency: to.upcase)
      if rate_record && rate_record.fetched_at >= TTL.ago
        return { rate: rate_record.rate, fetched_at: rate_record.fetched_at }
      end

      fetched = Rates::Fetcher.call(from: from, to: to)
      upsert_rate(from, to, fetched[:rate], fetched[:fetched_at])
      fetched
    end

    private

    def self.upsert_rate(from, to, rate, fetched_at)
      rec = ExchangeRate.find_or_initialize_by(
        base_currency: from.upcase,
        target_currency: to.upcase
      )
      rec.rate = rate
      rec.fetched_at = fetched_at
      rec.save
    end
  end
end
