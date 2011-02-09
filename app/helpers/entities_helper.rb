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
      :viewrecords => true,
      :onSelectRow => "function(cell)
      {
        document.getElementById('entity_tag').value = cell;
        document.getElementById('change_entity').disabled = false;
        document.getElementById('change_entity').parentNode.parentNode.action =
          '/entities/' + $('#entities_list').getCell(cell, 'id') + '/edit';
      }".to_json_var,
      :beforeSelectRow =>	"function()
      {
        if (canSelect) return true;
        return false;
      }".to_json_var
    }]

    jqgrid_api 'entities_list', grid, options

  end

end
