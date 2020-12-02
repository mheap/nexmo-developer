require 'spec_helper'

RSpec.describe 'Android docs', type: :request do
  let(:app) { Rack::Builder.new.run Rails.application }

  context 'SDK reference' do
    it 'redirects to the proper path' do
      get '/client-sdk/sdk-documentation/android/android'

      expect(last_response).to be_redirect
      expect(last_response.headers['Location']).to eq('http://example.org/sdk/stitch/android/index')
    end

    it 'renders successsfully' do
      get '/sdk/stitch/android/index'

      expect(last_response.status).to be(200)
    end
  end

  context 'Release Notes' do
    it 'renders successsfully' do
      get '/client-sdk/sdk-documentation/android/release-notes'

      expect(last_response.status).to be(200)
    end
  end
end
