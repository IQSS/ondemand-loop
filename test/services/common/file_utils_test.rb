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
end
