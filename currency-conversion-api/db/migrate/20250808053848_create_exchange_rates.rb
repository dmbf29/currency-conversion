class CreateExchangeRates < ActiveRecord::Migration[8.0]
  def change
    create_table :exchange_rates do |t|
      t.string  :base_currency,   null: false, limit: 3
      t.string  :target_currency, null: false, limit: 3
      t.decimal :rate,            null: false, precision: 18, scale: 10
      t.datetime :fetched_at,     null: false

      t.timestamps
    end
    add_index :exchange_rates, [ :base_currency, :target_currency ], unique: true
  end
end
