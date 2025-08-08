class Conversion < ApplicationRecord
  include CurrencyValidations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :rate_used, presence: true, numericality: { greater_than: 0 }
  validates :converted_amount, presence: true, numericality: { greater_than: 0 }
  validates :rate_fetched_at, presence: true
end
