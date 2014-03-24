module ApplicationHelper
  COLOR_ORDER  = ["green", "yellow", "red", "gray"]
  STATUS_ORDER = ["success", "rebuilding", "failure", "down"]

  def color_for_status(status)
    COLOR_ORDER[STATUS_ORDER.index(status)]
  end
end
