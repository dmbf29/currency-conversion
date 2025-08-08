module CurrencyValidations
  extend ActiveSupport::Concern

  ISO_CURRENCY_CODE = /\A[A-Z]{3}\z/

  included do
    before_validation :normalize_currencies
    validates :base_currency,  presence: true, format: { with: ISO_CURRENCY_CODE }
    validates :target_currency, presence: true, format: { with: ISO_CURRENCY_CODE }
    validate  :different_currencies
  end

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
