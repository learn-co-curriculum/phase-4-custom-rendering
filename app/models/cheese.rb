class Cheese < ApplicationRecord
  
  def summary
    "#{name}: $#{price}"
  end

end
