# frozen_string_literal: true
require 'test_helper'

class FileBrowserHelperTest < ActionView::TestCase
  include FileBrowserHelper

  test 'browser_entry_icon returns folder icon for folders' do
    File.stubs(:directory?).with('/path/to/folder').returns(true)
    File.stubs(:file?).with('/path/to/folder').returns(false)
    File.stubs(:size).with('/path/to/folder').returns(4096)

    folder_entry = FileBrowserController::DirectoryEntry.new(name: "subdir", path: "/path/to/folder")

    assert_equal 'bi-folder-fill', browser_entry_icon(folder_entry)
  end

  test 'browser_entry_icon returns file icon for files' do
    File.stubs(:directory?).with('/path/to/file.txt').returns(false)
    File.stubs(:file?).with('/path/to/file.txt').returns(true)
    File.stubs(:size).with('/path/to/file.txt').returns(1024)

    file_entry = FileBrowserController::DirectoryEntry.new(name: "testfile.txt", path: "/path/to/file.txt")

    assert_equal 'bi-file-earmark', browser_entry_icon(file_entry)
  end

  test 'browser_entry_icon returns unsupported icon for unsupported types' do
    File.stubs(:directory?).with('/path/to/link').returns(false)
    File.stubs(:file?).with('/path/to/link').returns(false)
    File.stubs(:size).with('/path/to/link').returns(0)

    unsupported_entry = FileBrowserController::DirectoryEntry.new(name: "test.link", path: "/path/to/link")

    assert_equal 'bi-slash-circle', browser_entry_icon(unsupported_entry)
  end

  test 'browser_entry_icon handles edge case when entry is neither file nor folder' do
    File.stubs(:directory?).with('/path/to/special').returns(false)
    File.stubs(:file?).with('/path/to/special').returns(false)
    File.stubs(:size).with('/path/to/special').returns(0)

    unsupported_entry = FileBrowserController::DirectoryEntry.new(name: "special", path: "/path/to/special")

    assert_equal 'bi-slash-circle', browser_entry_icon(unsupported_entry)
  end
end