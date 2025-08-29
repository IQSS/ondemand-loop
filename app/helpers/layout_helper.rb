# app/helpers/layout_helper.rb
module LayoutHelper
  # Returns true if we are on a given controller/action
  def on_page?(controller: nil, action: nil)
    (controller.nil? || params[:controller] == controller.to_s) &&
      (action.nil? || params[:action] == action.to_s)
  end

  def on_project_index?
    on_page?(controller: 'projects', action: 'index')
  end

  def on_explore?
    on_page?(controller: 'explore')
  end
end
