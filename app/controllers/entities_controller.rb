class EntitiesController < ApplicationController
  
  def index
    @entities = Entity.all
  end

  def new
    @entity = Entity.new
  end

  def edit
    @entity = Entity.find(params[:id])
  end

  def create
    @entity = Entity.new(params[:entity])
    if !@entity.save
      render :action => "new"
    end
  end

  def update
  end

end
