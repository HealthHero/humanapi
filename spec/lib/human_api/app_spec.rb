require 'spec_helper'

describe HumanApi::App do
  let(:app)    { described_class }

  describe ".humans" do
    let(:humans) { app.humans }
    let(:human)  { humans[0] }

    it 'gets a listing of humans as a hash' do
      VCR.use_cassette :get_humans do
        expect(human['humanId']).to    eq 'abcd'
        expect(human['externalId']).to eq '0001'
        expect(human['appId']).to      eq 'APP_ID'
        expect(human['createdAt']).to  eq '2014-09-17T23:38:55.073Z'
        expect(human['updatedAt']).to  eq '2015-05-28T16:23:56.859Z'
      end
    end
  end

  describe ".create_human" do
    let(:human)  { app.create_human 'test_user' }

    context "when successful" do
      it 'returns the parsed response' do
        VCR.use_cassette :create_human_success do
          expect(human['humanId']).to    eq 'abcd'
          expect(human['externalId']).to eq 'test_user'
          expect(human['appId']).to      eq 'CLIENT_ID'
          expect(human['createdAt']).to  eq '2015-09-01T18:18:18.500Z'
          expect(human['updatedAt']).to  eq '2015-09-01T18:19:55.177Z'
        end
      end
    end

    context "when unauthorized" do
      context "with a proc set" do
        before { expect(HumanApi.config).to receive(:handle_access_error).exactly(:twice).and_return ->e { e.class.to_s } }

        it 'calls the proc' do
          expect(app.create_human 'joe').to eq 'Nestful::UnauthorizedAccess'
        end
      end

      context "with raise_access_errors set" do
        before { expect(HumanApi.config).to receive(:raise_access_errors).and_return true }

        it 'raises a Nestful error' do
          expect { app.create_human 'joe' }.to raise_error Nestful::UnauthorizedAccess
        end
      end

      context "without raise_access_errors set" do
        before { expect(HumanApi.config).to receive(:raise_access_errors).and_return false }

        it 'just returns false' do
          expect(app.create_human 'joe').to eq false
        end
      end
    end

    context "when unsuccesful" do
      xit '.. need to think of a way to make this fail :p'
    end
  end

  describe ".delete_human" do
    it "returns true when all is well" do
      VCR.use_cassette :delete_human_success do
        expect(app.delete_human 'test_user').to eq true
      end
    end
  end
end
