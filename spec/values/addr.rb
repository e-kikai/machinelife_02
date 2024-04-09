require 'rails_helper'

RSpec.describe Addr do
  let(:addr) { Addr.new("大阪府", "岸和田市", "岡山町446") }

  describe 'テスト' do
    it '住所表示の出力' do
      expect(addr.to_s).to eq "大阪府 岸和田市 岡山町446"
    end
  end

end