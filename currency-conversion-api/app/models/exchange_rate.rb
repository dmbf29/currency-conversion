class ExchangeRate < ApplicationRecord
  include CurrencyValidations
  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :fetched_at, presence: true
  validates :base_currency, uniqueness: { scope: :target_currency }
end
