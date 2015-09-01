require 'spec_helper'

describe HumanApi::Human do
  let(:token)   { ENV['HUMAN_API_HUMAN_TOKEN'] || 'token' }
  let(:human)   { described_class.new access_token: token  }

  describe "#summary" do
    let(:response) { human.summary.body }
    let(:summary)  { JSON.parse response }

    it 'returns a summary' do
      VCR.use_cassette :get_summary_success do
        expect(summary['humanId']).to         eq 'humanID'
        expect(summary['createdAt']).to       eq '2015-07-23T18:29:18.157Z'
        expect(summary['bloodGlucose']).to    eq Hash.new
        expect(summary['bloodOxygen']).to     eq Hash.new
        expect(summary['bloodPressure']).to   eq Hash.new
        expect(summary['bmi']).to             eq Hash.new
        expect(summary['height']).to          eq Hash.new
        expect(summary['heartRate']).to       eq Hash.new
        expect(summary['sleepSummary']).to    eq Hash.new
        expect(summary['bodyFat']).to         eq 'id' => "id", "timestamp" => "2015-08-14T00:00:00.000Z", "source" => "runkeeper", "value" => 8.0559, "unit" => "%"
        expect(summary['weight']).to          eq 'id' => "id", "timestamp" => "2015-08-14T00:00:00.000Z", "source" => "runkeeper", "value" => 62.483, "unit" => "kg"
        expect(summary['activitySummary']).to eq 'id' => "id", "date" => "", "duration" => 7076, "distance" => 21167.628734835, "sedentary" => 0, "light" => 0, "moderate" => 0, "vigorous" => 0, "total" => 0, "steps" => 0, "calories" => 1436, "source"=>"runkeeper"
      end
    end
  end

  describe "#profile" do
    let(:profile) { human.profile }

    it 'returns the profile as a hash' do
      VCR.use_cassette :get_profile_success do
        expect(profile['userId']).to          eq 'userId'
        expect(profile['humanId']).to         eq 'humanID'
        expect(profile['email']).to           eq 'justin@humanapi.co'
        expect(profile['createdAt']).to       eq '2015-07-23T18:29:18.157Z'
        expect(profile['defaultTimeZone']).to eq 'name' => "UTC"
      end
    end
  end

  describe "#activities" do
    let(:response) { human.query :activities, options }
    let(:options)  { {} }
    let(:context)  { '' }

    around(:each) do |example|
      VCR.use_cassette("get_activities#{context}") { example.run }
    end

    context "by default" do
      let(:first_activity) { response[0] }

      it "returns them as a giant array of hashes" do
        expect(response.class).to eq Array
        expect(response.size).to  eq 50
      end

      it "has activity data" do
        expect(first_activity['id']).to         eq "55e37dd14a99f60b00f9ef96"
        expect(first_activity['userId']).to     eq "55b1327e7313370100c17161"
        expect(first_activity['startTime']).to  eq "2015-08-30T13:40:00.000Z"
        expect(first_activity['endTime']).to    eq "2015-08-30T15:37:56.000Z"
        expect(first_activity['tzOffset']).to   eq "-06:00"
        expect(first_activity['type']).to       eq "running"
        expect(first_activity['source']).to     eq "runkeeper"
        expect(first_activity['duration']).to   eq 7076
        expect(first_activity['distance']).to   eq 21167.628734835
        expect(first_activity['steps']).to      eq 0
        expect(first_activity['calories']).to   eq 1436
        expect(first_activity['sourceData']).to eq Hash.new
        expect(first_activity['createdAt']).to  eq "2015-08-30T22:04:01.355Z"
        expect(first_activity['updatedAt']).to  eq "2015-08-30T22:04:01.355Z"
        expect(first_activity['humanId']).to    eq "ef30511710618584fb02a34e5b5c1f7f"
      end
    end

    context "requesting metadata" do
      let(:options) { {return_metadata: true} }

      it 'returns useful metadata' do
        expect(response.class).to                    eq Nestful::Response
        expect(response.headers['x-total-count']).to eq '234'
        expect(response.headers['link'][1..73]).to   eq "https://api.humanapi.co/v1/human/activities?access_token=token&offset=50>"
      end
    end

    context "with an offset and limit" do
      let(:options) { {offset: 51, limit: 2} }
      let(:context) { '_a_few' }

      it "gets just what's requested" do
        expect(response.size).to eq 2
      end
    end

    context "requesting full set through pagination" do
      let(:options) { {fetch_all: true} }
      let(:context) { '_fetch_all' }

      it 'goes crazy and gets them all' do
        expect(response.count).to eq 234
      end

      context "with a callback" do
        let(:context) { '_fetch_all' }
        let(:foo)     { double 'Nothing' }
        let(:options) { {fetch_all: true, handle_data: ->data { foo.do_stuff data['id'] }} }

        it 'calls the callback on them all' do
          expect(foo).to receive(:do_stuff).exactly(234).times.and_return true
          expect(response).to be true
        end

        it 'returns false if one errors' do
          expect(foo).to receive(:do_stuff).exactly(:once).and_return false
          expect(foo).to receive(:do_stuff).exactly(233).times.and_return true
          expect(response).to be false
        end
      end
    end
  end

  TESTED = %i{profile activities}
  (described_class::AVAILABLE_METHODS - TESTED).each do |meth|
    describe "##{meth}" do
      xit "needs testing!"
    end
  end
end
