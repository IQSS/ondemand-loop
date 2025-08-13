# frozen_string_literal: true
require 'test_helper'

class Common::FileUtilsTest < ActiveSupport::TestCase
  def setup
    @utils = Common::FileUtils.new
  end

  test 'normalize_name should parameterize string with underscores' do
    input = 'My Test/File.txt'
    expected = 'my_test_file_txt'
    assert_equal expected, @utils.normalize_name(input)
  end

  test 'metadata_file should generate yml path from normalized filename' do
    result = @utils.metadata_file('/tmp', 'My Test/File.txt')
    assert_equal '/tmp/my_test_file_txt.yml', result
  end

  test 'unique_filename should return original filename if metadata file does not exist' do
    File.stubs(:exist?).returns(false)
    filename = 'data.csv'
    result = @utils.unique_filename('/tmp', filename)
    assert_equal filename, result
  end

  test 'unique_filename should return incremented filename if metadata file exists' do
    # Simulate first check exists, second doesn't
    File.stubs(:exist?).returns(true).then.returns(false)

    result = @utils.unique_filename('/tmp', 'data.csv', delimiter: '_')
    assert_equal '/data_1.csv', result
  end

  test 'unique_filename should raise error after max_attempts' do
    File.stubs(:exist?).returns(true)

    assert_raises(RuntimeError, /after 3 attempts/) do
      @utils.unique_filename('/tmp', 'data.csv', max_attempts: 3)
    end
  end

  test 'make_download_file_unique should update filename and id' do
    fake_file = OpenStruct.new(project_id: 123, filename: 'my file.csv')
    Project.stubs(:download_files_directory).with(123).returns('/tmp')
    @utils.stubs(:unique_filename).returns('my_file_1.csv')

    result = @utils.make_download_file_unique(fake_file)

    assert_equal 'my_file_1.csv', result.filename
    assert_equal 'my_file_1_csv', result.id
  end

  test 'normalize_name handles filenames without extension' do
    input = 'My File'
    expected = 'my_file'
    assert_equal expected, @utils.normalize_name(input)
  end

  test 'normalize_name handles filenames with multiple dots' do
    input = 'archive.tar.gz'
    expected = 'archive_tar_gz'
    assert_equal expected, @utils.normalize_name(input)
  end

  test 'metadata_file handles file with no extension' do
    result = @utils.metadata_file('/tmp', 'My Report')
    assert_equal '/tmp/my_report.yml', result
  end

  test 'metadata_file handles nested directories in filename' do
    result = @utils.metadata_file('/tmp', '2024/files/my report.csv')
    assert_equal '/tmp/2024_files_my_report_csv.yml', result
  end

  test 'normalize_name handles unicode and special characters' do
    input = 'Résumé @ Test—File 123.txt'
    expected = 'resume_test_file_123_txt'
    assert_equal expected, @utils.normalize_name(input)
  end

  test 'unique_filename handles files with no extension' do
    File.stubs(:exist?).returns(true).then.returns(false)
    result = @utils.unique_filename('/tmp', 'report', delimiter: '-')
    assert_equal '/report-1', result
  end

  test 'unique_filename handles filenames with multiple dots' do
    File.stubs(:exist?).returns(true).then.returns(false)
    result = @utils.unique_filename('/tmp', 'archive.tar.gz', delimiter: '_')
    assert_equal '/archive.tar_1.gz', result
  end

  test 'make_download_file_unique normalizes updated filename correctly' do
    fake_file = OpenStruct.new(project_id: 1, filename: 'my report.txt')
    Project.stubs(:download_files_directory).returns('/tmp')
    @utils.stubs(:unique_filename).returns('my_report_1.txt')

    result = @utils.make_download_file_unique(fake_file)

    assert_equal 'my_report_1.txt', result.filename
    assert_equal 'my_report_1_txt', result.id
  end

  test 'move_project_downloads moves tracked files to new directory' do
    project = create_project
    file1 = create_download_file(project)
    file2 = create_download_file(project)
    file2.filename = "subdir/#{file2.filename}" # simulate nested path
    project.stubs(:download_files).returns([file1, file2])

    old_dir = Dir.mktmpdir
    new_dir = Dir.mktmpdir

    FileUtils.mkdir_p(File.join(old_dir, 'subdir'))
    File.write(File.join(old_dir, file1.filename), 'file A')
    File.write(File.join(old_dir, file2.filename), 'file B')

    result = @utils.move_project_downloads(project, old_dir, new_dir)

    assert_equal true, result
    assert File.exist?(File.join(new_dir, file1.filename))
    assert File.exist?(File.join(new_dir, file2.filename))
    refute File.exist?(File.join(old_dir, file1.filename))
    refute File.exist?(File.join(old_dir, file2.filename))
  ensure
    FileUtils.rm_rf(old_dir)
    FileUtils.rm_rf(new_dir)
  end

  test 'move_project_downloads skips missing files and continues' do
    project = create_project
    missing_file = create_download_file(project)
    existing_file = create_download_file(project)
    project.stubs(:download_files).returns([missing_file, existing_file])

    old_dir = Dir.mktmpdir
    new_dir = Dir.mktmpdir

    File.write(File.join(old_dir, existing_file.filename), 'present')

    result = @utils.move_project_downloads(project, old_dir, new_dir)

    assert_equal true, result
    assert File.exist?(File.join(new_dir, existing_file.filename))
    refute File.exist?(File.join(old_dir, existing_file.filename))
  ensure
    FileUtils.rm_rf(old_dir)
    FileUtils.rm_rf(new_dir)
  end

  test 'move_project_downloads does nothing if old_dir equals new_dir' do
    dir = Dir.mktmpdir
    project = create_project
    file = create_download_file(project)
    project.stubs(:download_files).returns([file])

    File.write(File.join(dir, file.filename), 'content')

    result = @utils.move_project_downloads(project, dir, dir)

    assert_nil result
    assert File.exist?(File.join(dir, file.filename))
  ensure
    FileUtils.rm_rf(dir)
  end

  test 'move_project_downloads removes old_dir if empty after move' do
    project = create_project
    file = create_download_file(project)
    project.stubs(:download_files).returns([file])

    old_dir = Dir.mktmpdir
    new_dir = Dir.mktmpdir

    File.write(File.join(old_dir, file.filename), 'content')

    @utils.move_project_downloads(project, old_dir, new_dir)

    refute Dir.exist?(old_dir), 'old_dir should be deleted if empty'
  ensure
    FileUtils.rm_rf(old_dir)
    FileUtils.rm_rf(new_dir)
  end

  test 'move_project_downloads does not remove old_dir if not empty' do
    project = create_project
    moved_file = create_download_file(project)
    project.stubs(:download_files).returns([moved_file])

    old_dir = Dir.mktmpdir
    new_dir = Dir.mktmpdir

    File.write(File.join(old_dir, moved_file.filename), 'content')
    File.write(File.join(old_dir, 'untracked.txt'), 'stay here')

    @utils.move_project_downloads(project, old_dir, new_dir)

    assert Dir.exist?(old_dir), 'old_dir should not be removed if not empty'
    assert File.exist?(File.join(old_dir, 'untracked.txt'))
  ensure
    FileUtils.rm_rf(old_dir)
    FileUtils.rm_rf(new_dir)
  end
end

