module ActsAsPage

  def page
    @page
  end

  def per_page
    @per_page
  end

  def total_count
    @total_count
  end

  def to_s
    start_index = (@page - 1) * @per_page
    end_index = [start_index + @per_page, total_count].min
    "#{start_index + 1} to #{end_index} of #{total_count} results"
  end

  def total_pages
    (total_count.to_f / @per_page).ceil
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