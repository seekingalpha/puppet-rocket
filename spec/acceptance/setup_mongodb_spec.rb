require 'spec_helper_acceptance'

describe 'rocketchat::database' do
  let(:manifest) {
    <<-EOS
     class { 'rocketchat::database':
      port => 27017,
      verbose => true,
      manage_repos => true,
      version => '5.0',
}

   EOS
  }

    context 'with all default value' do
      it 'should run without errors' do
        result = apply_manifest(manifest, :catch_failures => true)
        expect(result.exit_code).to eq 2
      end
    end
end
