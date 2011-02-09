class EntitiesController < ApplicationController
  
  def index
    @columns = ['tag', 'id']
    @entities = Entity.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => json_for_jqgrid(@entities, @columns)
    end
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
    @entity = Entity.find(params[:id])
    if !@entity.update_attributes(params[:entity])
      render :action => "edit"
    end
  end
  
end
