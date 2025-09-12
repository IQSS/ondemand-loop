# frozen_string_literal: true

require 'test_helper'

class RepositoryActivityViewTest < ActionView::TestCase
  test 'renders global repository activity only when project_id not provided' do
    service = mock('service')
    global_items = [
      OpenStruct.new(url: 'https://example.com/dataset1', type: 'zenodo', date: Time.zone.now, title: 'Global Dataset 1', note: 'research'),
      OpenStruct.new(url: 'https://dataverse.org/dataset2', type: 'dataverse', date: Time.zone.now - 2.hours, title: 'Global Dataset 2', note: 'analysis')
    ]
    service.stubs(:global).returns(global_items)
    service.stubs(:project_downloads).with(nil).returns([])
    Repo::RepoActivityService.stubs(:new).returns(service)

    view.stubs(:connector_icon).returns('')
    view.stubs(:params).returns(ActionController::Parameters.new)

    html = render partial: 'widgets/repository_activity'

    # Parse HTML document for structure validation
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    # Check basic HTML structure - main container
    assert_equal 1, doc.css('#repository-items-tabs').count, 'Should have main repository items tabs container'

    # Check tab navigation structure
    nav_tabs = doc.css('.nav.nav-tabs')
    assert_equal 1, nav_tabs.count, 'Should have one nav tabs container'
    
    # Should only have global tab button when no project_id
    tab_buttons = nav_tabs.css('button.nav-link')
    assert_equal 1, tab_buttons.count, 'Should have only 1 tab button (global only)'
    
    # Verify global tab button
    global_tab_button = doc.css('#repository-items-global-tab')
    assert_equal 1, global_tab_button.count, 'Should have global tab button'
    assert_includes global_tab_button.first['class'], 'active', 'Global tab should be active by default'
    assert_includes global_tab_button.first.content, I18n.t('widgets.repository_activity.tab_global_label')
    
    # Verify project tab button should NOT be present
    project_tab_button = doc.css('#repository-items-project-tab')
    assert_equal 0, project_tab_button.count, 'Should not have project tab button when no project_id'

    # Check tab content structure
    tab_content = doc.css('.tab-content')
    assert_equal 1, tab_content.count, 'Should have one tab content container'
    
    # Verify global tab pane
    global_tab_pane = doc.css('#repository-items-global.tab-pane')
    assert_equal 1, global_tab_pane.count, 'Should have global tab pane'
    assert_includes global_tab_pane.first['class'], 'active', 'Global tab pane should be active'
    
    # Verify project tab pane should NOT be present
    project_tab_pane = doc.css('#repository-items-project.tab-pane')
    assert_equal 0, project_tab_pane.count, 'Should not have project tab pane when no project_id'

    # Check content list
    global_list = global_tab_pane.css('ul.list-unstyled')
    assert_equal 1, global_list.count, 'Global tab should have one list'

    # Check items count
    global_items_li = global_list.css('li.card')
    assert_equal 2, global_items_li.count, 'Should have 2 global items'

    # Verify content includes expected data
    assert_includes html, 'Global Dataset 1'
    assert_includes html, 'Global Dataset 2'
    assert_includes html, 'https://example.com/dataset1'
    assert_includes html, 'https://dataverse.org/dataset2'

    # Check forms and hidden fields (2 forms for 2 global items)
    forms = doc.css('form')
    assert_equal 2, forms.count, 'Expected 2 forms for 2 global items'

    # Assert that all forms contain repo_url and active_project hidden fields
    forms.each_with_index do |form, index|
      repo_url_field = form.css('input[type="hidden"][name="repo_url"]')
      active_project_field = form.css('input[type="hidden"][name="active_project"]')

      assert_equal 1, repo_url_field.count, 'Each form should have one repo_url hidden field'
      assert_equal 1, active_project_field.count, 'Each form should have one active_project hidden field'

      # Verify the active_project field has the correct value (should be empty when no project_id)
      assert_equal '', active_project_field.first['value'], 'active_project field should be empty when no project_id provided'

      # Verify the repo_url field has the correct value
      expected_url = global_items[index].url
      assert_equal expected_url, repo_url_field.first['value'], 'repo_url field should contain the item URL'
    end
  end

  test 'renders both global and project repository activity tabs when project_id provided' do
    project_id = '123'

    service = mock('service')
    global_items = [
      OpenStruct.new(url: 'https://global.example.com/dataset', type: 'zenodo', date: Time.zone.now, title: 'Global Dataset', note: 'research')
    ]
    project_downloads = [
      OpenStruct.new(url: '/project/new', type: 'dataverse', date: Time.zone.now, title: 'Project Download 1', note: 'dataset'),
      OpenStruct.new(url: '/project/old', type: 'zenodo', date: Time.zone.now - 1.day, title: 'Project Download 2', note: 'analysis')
    ]
    service.stubs(:global).returns(global_items)
    service.stubs(:project_downloads).with(project_id).returns(project_downloads)
    Repo::RepoActivityService.stubs(:new).returns(service)

    view.stubs(:connector_icon).returns('')
    view.stubs(:params).returns(ActionController::Parameters.new(project_id: project_id))

    html = render partial: 'widgets/repository_activity'

    # Parse HTML document for structure validation
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    # Check basic HTML structure - main container
    assert_equal 1, doc.css('#repository-items-tabs').count, 'Should have main repository items tabs container'

    # Check tab navigation structure
    nav_tabs = doc.css('.nav.nav-tabs')
    assert_equal 1, nav_tabs.count, 'Should have one nav tabs container'
    
    # Check that both tab buttons are present
    tab_buttons = nav_tabs.css('button.nav-link')
    assert_equal 2, tab_buttons.count, 'Should have 2 tab buttons (global and project)'
    
    # Verify global tab button
    global_tab_button = doc.css('#repository-items-global-tab')
    assert_equal 1, global_tab_button.count, 'Should have global tab button'
    assert_includes global_tab_button.first['class'], 'active', 'Global tab should be active by default'
    assert_includes global_tab_button.first.content, I18n.t('widgets.repository_activity.tab_global_label')
    
    # Verify project tab button
    project_tab_button = doc.css('#repository-items-project-tab')
    assert_equal 1, project_tab_button.count, 'Should have project tab button'
    assert_includes project_tab_button.first.content, I18n.t('widgets.repository_activity.tab_project_label')

    # Check tab content structure
    tab_content = doc.css('.tab-content')
    assert_equal 1, tab_content.count, 'Should have one tab content container'
    
    # Verify global tab pane
    global_tab_pane = doc.css('#repository-items-global.tab-pane')
    assert_equal 1, global_tab_pane.count, 'Should have global tab pane'
    assert_includes global_tab_pane.first['class'], 'active', 'Global tab pane should be active'
    
    # Verify project tab pane  
    project_tab_pane = doc.css('#repository-items-project.tab-pane')
    assert_equal 1, project_tab_pane.count, 'Should have project tab pane'

    # Check content lists
    global_list = global_tab_pane.css('ul.list-unstyled')
    project_list = project_tab_pane.css('ul.list-unstyled')
    assert_equal 1, global_list.count, 'Global tab should have one list'
    assert_equal 1, project_list.count, 'Project tab should have one list'

    # Check items count
    global_items_li = global_list.css('li.card')
    project_items_li = project_list.css('li.card')
    assert_equal 1, global_items_li.count, 'Should have 1 global item'
    assert_equal 2, project_items_li.count, 'Should have 2 project items'

    # Verify content includes expected data
    assert_includes html, 'Global Dataset'
    assert_includes html, 'Project Download 1'
    assert_includes html, 'Project Download 2'
    assert_includes html, '/project/new'
    assert_includes html, '/project/old'

    # Check forms and hidden fields (3 total forms: 1 global + 2 project)
    forms = doc.css('form')
    assert_equal 3, forms.count, 'Expected 3 forms total (1 global + 2 project items)'
    
    # Assert that all forms contain required hidden fields
    forms.each do |form|
      repo_url_field = form.css('input[type="hidden"][name="repo_url"]')
      active_project_field = form.css('input[type="hidden"][name="active_project"]')
      
      assert_equal 1, repo_url_field.count, 'Each form should have one repo_url hidden field'
      assert_equal 1, active_project_field.count, 'Each form should have one active_project hidden field'
      
      # Verify the active_project field has the correct value
      assert_equal project_id, active_project_field.first['value'], 'active_project field should contain the project_id'
    end
  end
end
