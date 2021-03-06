require 'spec_helper'

describe Rack::App::File::Server do
  let(:instance) { described_class.new(root_folder, :to => namespace) }
  let(:root_folder) { '/spec/fixtures' }
  let(:request_method) { 'GET' }

  let(:env) do
    {
        ::Rack::PATH_INFO => path_info,
        ::Rack::REQUEST_METHOD => request_method
    }
  end

  describe '#call' do
    subject { instance.call(env) }

    context 'when namespace not defined it should use "/" as default' do
      let(:namespace) { nil }

      context 'and requested file exist' do
        let(:path_info) { '/raw.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 200
        end

        it 'should set the response headers' do
          expect(subject[1].keys).to match_array ["Last-Modified", "Content-Type", "Content-Length"]
        end

        it 'should response with a ::Rack::File instance' do
          expect(subject[2]).to be_a ::Rack::File
        end

        it 'should include the file content' do
          file_content = []
          subject[2].each { |line| file_content << line }
          expect(file_content.join).to eq "hello world!\nhow you doing?"
        end

      end

      context 'and requested file exist' do
        let(:path_info) { '/invalid.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 404
        end

        it 'should include the file content' do
          expect(subject[2].join).to eq "File not found: /invalid.txt\n"
        end

      end

    end

    context 'when namespace set to "/"' do
      let(:namespace) { '/' }

      context 'and requested file exist' do
        let(:path_info) { '/raw.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 200
        end

        it 'should set the response headers' do
          expect(subject[1].keys).to match_array ["Last-Modified", "Content-Type", "Content-Length"]
        end

        it 'should response with a ::Rack::File instance' do
          expect(subject[2]).to be_a ::Rack::File
        end

        it 'should include the file content' do
          file_content = []
          subject[2].each { |line| file_content << line }
          expect(file_content.join).to eq "hello world!\nhow you doing?"
        end

      end

      context 'and requested file exist' do
        let(:path_info) { '/invalid.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 404
        end

        it 'should include the file content' do
          expect(subject[2].join).to eq "File not found: /invalid.txt\n"
        end

      end

    end

    context 'when namespace set to an alternative path such as "/something"' do
      let(:namespace) { '/something' }

      context 'and requested file exist' do
        let(:path_info) { '/something/raw.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 200
        end

        it 'should set the response headers' do
          expect(subject[1].keys).to match_array ["Last-Modified", "Content-Type", "Content-Length"]
        end

        it 'should response with a ::Rack::File instance' do
          expect(subject[2]).to be_a ::Rack::File
        end

        it 'should include the file content' do
          file_content = []
          subject[2].each { |line| file_content << line }
          expect(file_content.join).to eq "hello world!\nhow you doing?"
        end

      end

      context 'and requested file exist' do
        let(:path_info) { '/something/invalid.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 404
        end

        it 'should include the file content' do
          expect(subject[2].join).to eq "File not found: /invalid.txt\n"
        end

      end

    end

  end

end