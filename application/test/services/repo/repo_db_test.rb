# frozen_string_literal: true
require 'test_helper'
require 'tempfile'

class Repo::RepoDbTest < ActiveSupport::TestCase
  def setup
    @tempfile = Tempfile.new('repo_db_test')
    @db = Repo::RepoDb.new(db_path: @tempfile.path)
    @type = ConnectorType.get(:dataverse)
  end

  def teardown
    @tempfile.unlink
  end

  test 'should add and retrieve an entry' do
    @db.set('demo.org', type: @type, metadata: { token: 'abc123' })
    entry = @db.get('demo.org')

    assert entry
    assert_equal @type, entry.type
    assert_equal 'abc123', entry.metadata.token
    assert_not_nil entry.last_updated
  end

  test 'should update metadata' do
    @db.set('demo.org', type: @type, metadata: { token: 'abc123' })
    @db.update('demo.org', metadata: { token: 'xyz789', user: 'alice' })

    entry = @db.get('demo.org')
    assert_equal 'xyz789', entry.metadata.token
    assert_equal 'alice', entry.metadata.user
  end

  test 'should raise error when updating unknown domain' do
    assert_raises(ArgumentError, 'Unknown domain: unknown.org') do
      @db.update('unknown.org', metadata: { token: 'xyz789' })
    end
  end

  test 'should delete an entry' do
    @db.set('demo.org', type: @type, metadata: { token: 'abc123' })
    @db.delete('demo.org')

    assert_nil @db.get('demo.org')
    assert_equal 0, @db.size
  end

  test 'should return correct size and all entries' do
    @db.set('demo.org', type: @type)
    @db.set('example.com', type: @type)

    assert_equal 2, @db.size
    all = @db.all
    assert_kind_of Hash, all
    assert_equal %w[demo.org example.com].sort, all.keys.sort
  end

  test 'should persist and reload from file' do
    @db.set('demo.org', type: @type, metadata: { token: 'abc123' })

    reloaded = Repo::RepoDb.new(db_path: @tempfile.path)
    entry = reloaded.get('demo.org')

    assert entry
    assert_equal 'abc123', entry.metadata.token
  end

  test 'should not persist invalid type' do
    assert_raises(ArgumentError) do
      @db.set('demo.org', type: 'invalid')
    end
  end
end
