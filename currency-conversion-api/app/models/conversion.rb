class Conversion < ApplicationRecord
  before_validation :normalize_currencies
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :base_currency,  presence: true, format: { with: /\A[A-Z]{3}\z/ }
  validates :target_currency, presence: true, format: { with: /\A[A-Z]{3}\z/ }
  validates :rate_used, presence: true, numericality: { greater_than: 0 }
  validates :converted_amount, presence: true, numericality: { greater_than: 0 }
  validates :rate_fetched_at, presence: true
  validate  :different_currencies

  private

  def normalize_currencies
    self.base_currency   = base_currency&.strip&.upcase
    self.target_currency = target_currency&.strip&.upcase
  end

  def different_currencies
    return if base_currency.blank? || target_currency.blank?
    errors.add(:target_currency, "must be different from base_currency") if base_currency == target_currency
  end
end
