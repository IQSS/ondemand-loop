require "test_helper"

class ProjectTest < ActiveSupport::TestCase

  test "initialization should works" do
    target = Project.new(id: 'ab12345', name: 'test_project', download_dir: '/tmp/test_project')
    assert_equal 'ab12345', target.id
    assert_equal 'test_project', target.name
    assert_equal '/tmp/test_project', target.download_dir
  end

  test "should be valid when all fields are populated" do
    target = create_valid_project
    assert target.valid?
  end

  test "validations should fail due to blank value" do
    target = create_valid_project
    assert target.valid?

    target.id = ''
    refute target.valid?
    assert_includes target.errors[:id], "can't be blank"

    target.name = ''
    refute target.valid?
    assert_includes target.errors[:name], "can't be blank"

    target.download_dir = ''
    refute target.valid?
    assert_includes target.errors[:download_dir], "can't be blank"
  end

  test "to_hash" do
    target = create_valid_project
    expected_hash = {id: target.id, name: target.name, download_dir: target.download_dir}.stringify_keys
    assert_equal expected_hash, target.to_hash
  end

  test "to_json" do
    target = create_valid_project
    expected_json = {id: target.id, name: target.name, download_dir: target.download_dir}.to_json
    assert_equal expected_json, target.to_json
  end

  test "to_yaml" do
    target = create_valid_project
    expected_yaml = {id: target.id, name: target.name, download_dir: target.download_dir}.stringify_keys.to_yaml
    assert_equal expected_yaml, target.to_yaml
  end

  test "save with valid attributes" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      expected_file = File.join(dir, 'projects', target.id, 'metadata.yml')
      assert File.exist?(expected_file), "Project file was not created in the file system"
    end
  end

  test "save twice only creates one file" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      expected_directory = File.join(dir, 'projects', target.id)
      expected_file = File.join(expected_directory, 'metadata.yml')
      assert File.exist?(expected_file), "Project file was not created in the file system"
      assert_equal 1, Dir.glob(expected_directory).count

      assert target.save
      assert File.exist?(expected_file), "Project file was not created in the file system"
      assert_equal 1, Dir.glob(expected_directory).count
    end
  end

  test "save stopped due to invalid attributes" do
    in_temp_directory do |dir|
      target = create_valid_project
      target.id = ''
      refute target.save
      expected_file = File.join(dir, 'projects', target.id, 'metadata.yml')
      refute File.exist?(expected_file), "Project file was created in the file system"
    end
  end

  test "find does not find the record if it was not saved" do
    refute Project.find('456-789')
  end

  test "find retrieves the record if it was saved" do
    in_temp_directory do |dir|
      target = create_valid_project
      target.save
      assert Project.find(target.id)
    end
  end

  test "find retrieves the record with the same stored values" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      saved_project = Project.find(target.id)
      assert saved_project
      assert_equal 'ab12345', saved_project.id
      assert_equal 'test_project', saved_project.name
      assert_equal '/tmp/test_project', saved_project.download_dir
    end
  end

  test "find retrieves the correct record on multiple records" do
    in_temp_directory do |dir|
      target1 = create_valid_project(id: random_id, name: random_id)
      assert target1.save

      target2 = create_valid_project(id: random_id, name: random_id)
      assert target2.save

      target3 = create_valid_project(id: random_id, name: random_id)
      assert target3.save

      saved_project = Project.find(target2.id)
      assert saved_project
      assert_equal target2.id, saved_project.id
      assert_equal target2.name, saved_project.name
      assert_equal target2.download_dir, saved_project.download_dir
    end
  end

  test "all returns empty array if no records stored" do
    in_temp_directory do
      assert Project.all.empty?
    end
  end

  test "all returns an array with the saved entry" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      assert_equal 1, Project.all.size
      saved_project = Project.all.first
      assert saved_project
      assert_equal 'ab12345', saved_project.id
      assert_equal 'test_project', saved_project.name
      assert_equal '/tmp/test_project', saved_project.download_dir
    end
  end

  test "all returns an array with multiple entries sorted by creation date descendant" do
    in_temp_directory do |dir|
      target1 = create_valid_project(id: random_id, name: random_id)
      assert target1.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE

      target2 = create_valid_project(id: random_id, name: random_id)
      assert target2.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE
      target3 = create_valid_project(id: random_id, name: random_id)
      assert target3.save

      projects = Project.all
      assert 3, projects.size
      assert_equal target3.id, projects[0].id
      assert_equal target2.id, projects[1].id
      assert_equal target1.id, projects[2].id
    end
  end

  test "files default value is empty array" do
    in_temp_directory do
      target = create_valid_project
      assert target.save
      saved_project = Project.find(target.id)
      assert saved_project.files.empty?
    end
  end

  test "files handle a single file" do
    in_temp_directory do |dir|
      target = create_valid_project
      assert target.save
      file = create_download_file(target)
      assert file.save, file
      expected_file = File.join(dir, 'projects', target.id, 'files', "#{file.id}.yml")
      assert File.exist?(expected_file)

      saved_project = Project.find(target.id)
      project_files = saved_project.files
      assert_equal 1, project_files.count
      saved_file = project_files.first
      assert_equal file.id, saved_file.id
    end
  end

  test "files handle multiple files sorted by creation date descendent" do
    in_temp_directory do
      target = create_valid_project
      target.save
      file1 = create_download_file(target, id: 'saved_1')
      assert file1.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE
      file2 = create_download_file(target, id: 'saved_2')
      assert file2.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE
      file3 = create_download_file(target, id: 'saved_3')
      assert file3.save

      saved_project = Project.find(target.id)
      project_files = saved_project.files
      assert_equal 3, project_files.count
      assert_equal file3.id, project_files[0].id
      assert_equal file2.id, project_files[1].id
      assert_equal file1.id, project_files[2].id
    end
  end

  private

  def create_valid_project(id: 'ab12345', name: 'test_project', download_dir: '/tmp/test_project')
    Project.new(id: id, name: name, download_dir: download_dir)
  end

  def in_temp_directory
    Dir.mktmpdir do |dir|
      Project.stubs(:metadata_root_directory).returns(dir)
      DownloadFile.stubs(:metadata_root_directory).returns(dir)

      yield dir
    end
  end

end