FactoryBot.define do
  factory :exchange_rate do
    base_currency { "USD" }
    target_currency { "EUR" }
    rate { BigDecimal("0.85") }
    fetched_at { Time.current }
  end

  factory :exchange_rate_usd_to_jpy, class: 'ExchangeRate' do
    base_currency { "USD" }
    target_currency { "JPY" }
    rate { BigDecimal("110.50") }
    fetched_at { Time.current }
  end

  factory :exchange_rate_eur_to_gbp, class: 'ExchangeRate' do
    base_currency { "EUR" }
    target_currency { "GBP" }
    rate { BigDecimal("0.86") }
    fetched_at { Time.current }
  end
end
