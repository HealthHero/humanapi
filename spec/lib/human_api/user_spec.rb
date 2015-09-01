require 'spec_helper'

describe HumanApi::User do
  let(:user) { described_class }

  describe ".get_public_token" do
    it 'gets a public token' do
      VCR.use_cassette :get_public_token do
        expect(user.get_public_token 'human_id').to eq 'public_token'
      end
    end
  end
end
