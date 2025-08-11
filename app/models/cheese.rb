class Cheese < ApplicationRecord
  def show
    cheese = Cheese.find_by(id: params[:id])
    if cheese
      render json: cheese, except: %i[created_at updated_at], methods: [:summary]
    else
      # status: :not_found will produce a 404 status code
      render json: { error: 'Cheese not found' }, status: :not_found
    end
  end
end
