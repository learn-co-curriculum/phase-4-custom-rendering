class CheesesController < ApplicationController

  # GET /cheeses
  def index
    cheeses = Cheese.all
    render json: cheeses, only: [:id, :name, :price, :is_best_seller], methods: [:summary]

  end

  # GET /cheeses/:id
  def show
    cheese = Cheese.find_by(id: params[:id])
    if cheese
      render json: cheeses, only: [:id, :name, :price, :is_best_seller], methods: [:summary]
    else
      render json: { error: 'Cheese not found' }, status: :not_found
    end


    # render json: cheese
  end
  
  def summary 
    "#{name}: $#{price}"
  end

end
