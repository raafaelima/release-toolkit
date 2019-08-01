require 'spec_helper.rb'

describe Fastlane::Configuration do
  describe 'initialization' do
    it 'creates an empty config' do
      expect(subject.branch).to eq("")
      expect(subject.pinned_hash).to eq("")
      expect(subject.files_to_copy).to eq([])
      expect(subject.file_dependencies).to eq([])
    end
  end

  describe 'file reading/writing' do
    let(:configure_path) { 'path/to/.configure' }

    let(:configure_json) do
      {
        branch: "a_branch",
        pinned_hash: 'a_hash',
        files_to_copy: [ 'a_file_to_copy' ],
        file_dependencies: [ 'a_file_dependencies' ],
      }
    end
    let(:configure_json_string) { JSON.pretty_generate(configure_json) }

    subject { Fastlane::Configuration.from_file(configure_path) }

    before(:each) do
      allow(File).to receive(:read).with(configure_path).and_return(configure_json_string)
      allow(File).to receive(:write).with(configure_path, configure_json_string)
    end

    it 'reads instantiates the configuration object from JSON' do
      expect(subject.branch).to eq(configure_json[:branch])
      expect(subject.pinned_hash).to eq(configure_json[:pinned_hash])
      expect(subject.files_to_copy).to eq(configure_json[:files_to_copy])
      expect(subject.file_dependencies).to eq(configure_json[:file_dependencies])
    end

    it 'write the configuration to disk as JSON' do
      expect(File).to receive(:write).with(configure_path, configure_json_string)

      subject.save_to_file(configure_path)
    end
  end
end
