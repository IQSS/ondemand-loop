require 'rails_helper'

RSpec.describe DataverseHost, type: :model do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:sample_uri) { URI('https://example.com:443') }
  let(:another_sample_uri) { URI('https://another-example.com:443') }

  before do
    allow(DataverseHost).to receive(:metadata_root_directory).and_return(tmp_dir)
  end

  after do
    FileUtils.remove_entry(tmp_dir)
  end

  describe '#save and .find' do
    it 'saves a Dataverse Host to disk and retrieves it by id' do
      new_id = SecureRandom.uuid.to_s
      host = DataverseHost.new
      host.id = new_id
      host.hostname = 'example.com'
      host.port = 443
      host.scheme = 'https'
      host.save

      retrieved_host = DataverseHost.find(new_id)
      expect(retrieved_host).not_to be_nil
      expect(retrieved_host.hostname).to eq 'example.com'
      expect(retrieved_host.scheme).to eq 'https'
      expect(retrieved_host.id).to eq new_id
      expect(retrieved_host.full_name).to eq('https://example.com:443')
      expect(File.exist?(DataverseHost.filename_by_id(host.id))).to be true
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 1
      expect(DataverseHost.all.count).to eq 1
    end

    it 'saves a Dataverse Host to disk and tries to retrieve another by id' do
      new_id = SecureRandom.uuid.to_s
      host = DataverseHost.new
      host.id = new_id
      host.hostname = 'example.com'
      host.port = 443
      host.scheme = 'https'
      host.save

      retrieved_host = DataverseHost.find(SecureRandom.uuid.to_s)
      expect(retrieved_host).to be_nil
      expect(File.exist?(DataverseHost.filename_by_id(host.id))).to be true
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 1
      expect(DataverseHost.all.count).to eq 1
    end
  end

  describe '.all' do
    it 'returns and empty array' do
      expect(DataverseHost.all).to be_empty
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 0
    end

    it 'returns all saved hosts' do
      host1 = DataverseHost.new.tap do |h|
        h.id = SecureRandom.uuid.to_s
        h.hostname = 'host1.com'
        h.port = 80
        h.scheme = 'http'
      end
      host1.save

      host2 = DataverseHost.new.tap do |h|
        h.id = SecureRandom.uuid.to_s
        h.hostname = 'host2.com'
        h.port = 443
        h.scheme = 'https'
      end
      host2.save

      all_hosts = DataverseHost.all
      expect(all_hosts.count).to eq(2)
      expect(all_hosts.map(&:full_name)).to contain_exactly('http://host1.com:80', 'https://host2.com:443')
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 2
    end
  end

  describe '.find_by_uri' do
    before do
      host = DataverseHost.new.tap do |h|
        h.id = SecureRandom.uuid.to_s
        h.hostname = 'example.com'
        h.port = 443
        h.scheme = 'https'
      end
      host.save
    end

    it 'finds a host by its URI' do
      found_host = DataverseHost.find_by_uri(sample_uri)
      expect(found_host).not_to be_nil
      expect(found_host.full_name).to eq('https://example.com:443')
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 1
    end

    it 'try to find another host by its URI' do
      found_host = DataverseHost.find_by_uri(another_sample_uri)
      expect(found_host).to be_nil
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 1
    end
  end

  describe '.find_or_initialize_by_uri' do
    it 'tries to find an existing host and initializes a new one' do
      new_host = DataverseHost.find_or_initialize_by_uri(sample_uri)
      expect(new_host).not_to be_nil
      expect(new_host.full_name).to eq('https://example.com:443')
      expect(File.exist?(DataverseHost.filename_by_id(new_host.id))).to be true
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 1
    end

    it 'a second invocation of the method does not create a new entry' do
      new_host = DataverseHost.find_or_initialize_by_uri(sample_uri)
      retrieved_host = DataverseHost.find_or_initialize_by_uri(sample_uri)
      expect(new_host).not_to be_nil
      expect(new_host.full_name).to eq('https://example.com:443')
      expect(retrieved_host).not_to be_nil
      expect(retrieved_host.full_name).to eq('https://example.com:443')
      expect(File.exist?(DataverseHost.filename_by_id(new_host.id))).to be true
      expect(Dir.glob(File.join(DataverseHost.metadata_directory, "*.json")).count).to eq 1
      expect(DataverseHost.all.count).to eq 1
    end
  end
end
