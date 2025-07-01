class Page
  include ActsAsPage

  def initialize(items, page = 1, per_page = 10)
    @items = items
    @page = page.to_i < 1 ? 1 : page.to_i
    @per_page = per_page.to_i < 1 ? 10 : per_page.to_i
    @total_count = @items.count
  end

  def page_items
    start_index = (@page - 1) * @per_page
    @items.slice(start_index, @per_page) || []
  end
end