class CheesesController < ApplicationController
  # GET /cheeses
  def index
    cheeses = Cheese.all
    render json: cheese, except: %i[created_at updated_at], methods: [:summary]
  end

  # GET /cheeses/:id
  def show
    cheese = Cheese.find_by(id: params[:id])
    render json: {
      id: cheese.id,
      name: cheese.name,
      price: cheese.price,
      is_best_seller: cheese.is_best_seller
    }
  end
end
