module EntitiesHelper

  include JqgridsHelper

  def entities_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/entities',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag', 'id'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800 },
        { :name => 'id',   :index => 'id',    :width => 5, :hidden => true }
      ],
      :pager => '#entities_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'entities_list', grid, options

  end

end
