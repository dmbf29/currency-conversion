FactoryBot.define do
  factory :conversion do
    amount { BigDecimal("100.0") }
    base_currency { "USD" }
    target_currency { "EUR" }
    rate_used { BigDecimal("0.85") }
    converted_amount { BigDecimal("85.0") }
    rate_fetched_at { Time.current }
  end

  factory :conversion_usd_to_jpy, class: 'Conversion' do
    amount { BigDecimal("50.0") }
    base_currency { "USD" }
    target_currency { "JPY" }
    rate_used { BigDecimal("110.50") }
    converted_amount { BigDecimal("5525.0") }
    rate_fetched_at { Time.current }
  end

  factory :conversion_eur_to_gbp, class: 'Conversion' do
    amount { BigDecimal("200.0") }
    base_currency { "EUR" }
    target_currency { "GBP" }
    rate_used { BigDecimal("0.86") }
    converted_amount { BigDecimal("172.0") }
    rate_fetched_at { Time.current }
  end
end
