require 'test_helper'

class Zenodo::Handlers::RecordsTest < ActiveSupport::TestCase
  def setup
    @repo_url = OpenStruct.new(server_url: 'https://zenodo.org')
    @explorer = Zenodo::Handlers::Records.new('123')
  end

  test 'params schema includes expected keys' do
    assert_includes @explorer.params_schema, :repo_url
    assert_includes @explorer.params_schema, :project_id
    assert @explorer.params_schema.any? { |p| p.is_a?(Hash) && p.key?(:file_ids) }
  end

  test 'show renders record when found' do
    service = mock('service')
    service.expects(:find_record).with('123').returns(:record)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)
    res = @explorer.show(repo_url: @repo_url)
    assert res.success?
    assert_equal :record, res.locals[:record]
  end

  test 'show returns error when record missing' do
    service = mock('service')
    service.expects(:find_record).with('123').returns(nil)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)
    res = @explorer.show(repo_url: @repo_url)
    refute res.success?
  end

  test 'create initializes project and files' do
    service = mock('service')
    service.expects(:find_record).with('123').returns(:record)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)

    Project.stubs(:find).with('1').returns(nil)
    project = mock('project')
    project.stubs(:save).returns(true)
    project.stubs(:name).returns('Proj')
    project.stubs(:id).returns(1)

    file = mock('file')
    file.stubs(:valid?).returns(true)
    file.stubs(:save).returns(true)

    proj_service = mock('proj_service')
    proj_service.expects(:initialize_project).returns(project)
    proj_service.expects(:create_files_from_record).with(project, :record, ['f1']).returns([file])
    Zenodo::ProjectService.expects(:new).with('https://zenodo.org').returns(proj_service)

    res = @explorer.create(repo_url: @repo_url, file_ids: ['f1'], project_id: '1')
    assert res.success?
  end

  test 'create returns error when record not found' do
    service = mock('service')
    service.expects(:find_record).with('123').returns(nil)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)
    res = @explorer.create(repo_url: @repo_url, file_ids: [], project_id: '1')
    refute res.success?
  end
end
