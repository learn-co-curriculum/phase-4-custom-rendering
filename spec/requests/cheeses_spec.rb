require 'rails_helper'

RSpec.describe "Cheeses", type: :request do
  describe 'GET /cheeses/:id' do
    let!(:cheese) { Cheese.create!(name: "Cheddar", price: 3, is_best_seller: true) }

    it 'returns the cheese with the matching id' do
      get "/cheeses/#{cheese.id}"

      expect(response.body).to include_json({
        id: a_kind_of(Integer),
        name: 'Cheddar',
        price: 3,
        is_best_seller: true
      })
    end
  end
end
