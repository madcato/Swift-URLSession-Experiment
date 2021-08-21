class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :update, :destroy]

  # GET /todos
  def index
    @todos = Todo.all
    json_response(@todo)
  end

  # GET /todos/1
  def show
    json_response(@todo)
  end

  # POST /todos
  def create
    @todo = Todo.create!(todo_params)
    json_response(@todo)
  end

  # PATCH/PUT /todos/1
  def update
    @todo.update(todo_params)
    head :no_content
  end

  # DELETE /todos/1
  def destroy
    @todo.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.require(:todo).permit(:title, :created_by)
    end
end
