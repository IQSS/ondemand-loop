class Page
  include ActsAsPage

  def initialize(items, page = 1, per_page = 10, q: nil, filter_by: nil)
    @items = items
    @page = page.to_i < 1 ? 1 : page.to_i
    @per_page = per_page.to_i < 1 ? 10 : per_page.to_i
    @q = q
    @filter_by = filter_by
    @items = filter_items
    @total_count = @items.count
  end

  def page_items
    start_index = (@page - 1) * @per_page
    @items.slice(start_index, @per_page) || []
  end

  private

  def filter_items
    return @items unless @filter_by
    return @items unless q && q.to_s.strip != ''
    query = q.to_s.downcase
    @items.select do |item|
      if item.respond_to?(:[]) && item.key?(@filter_by)
        item[@filter_by].to_s.downcase.include?(query)
      elsif item.respond_to?(@filter_by)
        item.send(@filter_by).to_s.downcase.include?(query)
      else
        item.to_s.downcase.include?(query)
      end
    end
  end
end