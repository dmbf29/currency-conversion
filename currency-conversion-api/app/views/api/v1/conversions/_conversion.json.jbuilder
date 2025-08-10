json.id               conversion.id
json.amount           conversion.amount.to_f
json.base_currency    conversion.base_currency
json.target_currency  conversion.target_currency
json.converted_amount conversion.converted_amount.to_f
json.rate_used        conversion.rate_used.to_f
json.rate_timestamp   conversion.rate_fetched_at.iso8601
json.created_at       conversion.created_at.iso8601
