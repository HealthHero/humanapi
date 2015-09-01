require 'spec_helper'

describe HumanApi::Config do
  let(:config) { described_class.new }

  it 'sets some defaults' do
    expect(config.hardcore).to            be false
    expect(config.raise_access_errors).to be false
  end

  describe "#rewrite_human_model" do
    xit 'needs testing!'
  end
end
