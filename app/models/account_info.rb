class AccountInfo < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :max_products_count
  validates_presence_of :seo_field_identifier
  validates_presence_of :day_to_update
end
