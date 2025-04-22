class Page
  attr_reader :page, :per_page

  def initialize(items, page = 1, per_page = 10)
    @items = items
    @page = page.to_i < 1 ? 1 : page.to_i
    @per_page = per_page.to_i < 1 ? 10 : per_page.to_i
  end

  def page_items
    start_index = (@page - 1) * @per_page
    @items.slice(start_index, @per_page) || []
  end

  def to_s
    start_index = (@page - 1) * @per_page
    end_index = [start_index + @per_page, total_count].min
    "#{start_index + 1} to #{end_index} of #{total_count} results"
  end

  def total_count
    @items.size
  end

  def total_pages
    (@items.count.to_f / @per_page).ceil
  end

  def first_page?
    @page == 1
  end

  def last_page?
    @page == total_pages
  end

  def out_of_range?
    @page > total_pages
  end

  def next_page
    @page + 1 unless last_page? || out_of_range?
  end

  def prev_page
    @page - 1 unless first_page? || out_of_range?
  end
end