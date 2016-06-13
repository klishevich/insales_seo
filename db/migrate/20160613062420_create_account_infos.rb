class CreateAccountInfos < ActiveRecord::Migration
  def change
    create_table :account_infos do |t|
      t.references :account, index: true, foreign_key: true
      t.integer :max_products_count
      t.boolean :auto_update, default: false
      t.integer :seo_field_identifier
      t.integer :day_to_update
      t.boolean :allow_work, default: false
      t.date :last_seo_update

      t.timestamps null: false
    end
  end
end
