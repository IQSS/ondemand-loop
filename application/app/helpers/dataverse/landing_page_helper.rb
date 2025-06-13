module Dataverse::LandingPageHelper
  def link_to_landing_prev_page(installations_page, html_options = {})
    unless installations_page.first_page?
      html_options['aria-label'] = I18n.t("acts_as_page.link_prev_page_a11y_label")
      html_options[:title] = I18n.t("acts_as_page.link_prev_page_title")
      link_to("<", view_dataverse_landing_path(page: installations_page.prev_page), html_options)
    end
  end

  def link_to_landing_next_page(installations_page, html_options = {})
    unless installations_page.last_page?
      html_options['aria-label'] = I18n.t("acts_as_page.link_next_page_a11y_label")
      html_options[:title] = I18n.t("acts_as_page.link_next_page_title")
      link_to(">", view_dataverse_landing_path(page: installations_page.next_page), html_options)
    end
  end
end