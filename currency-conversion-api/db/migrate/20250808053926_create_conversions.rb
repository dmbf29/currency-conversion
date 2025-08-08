class CreateConversions < ActiveRecord::Migration[8.0]
  def change
    create_table :conversions do |t|
      t.decimal :amount,           null: false, precision: 18, scale: 6
      t.string  :base_currency,    null: false, limit: 3
      t.string  :target_currency,  null: false, limit: 3
      t.decimal :rate_used,        null: false, precision: 18, scale: 10
      t.decimal :converted_amount, null: false, precision: 18, scale: 6
      t.datetime :rate_fetched_at, null: false

      t.timestamps
    end
    add_index :conversions, [ :base_currency, :target_currency, :rate_fetched_at ]
  end
end
