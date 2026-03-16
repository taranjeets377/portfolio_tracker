class Stock < ApplicationRecord
  belongs_to :stock_sector
  belongs_to :stock_category
end
