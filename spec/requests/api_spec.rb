require 'spec_helper'

RSpec.describe 'SMS API docs', type: :request do
  let(:app) { Rack::Builder.new.run Rails.application }

  context 'external-accounts' do
    it 'renders successfully' do
      get '/api/external-accounts'

      expect(last_response.status).to be(200)
    end
  end

  context 'subscription' do
    it 'renders successfully' do
      get '/api/sms/us-short-codes/alerts/subscription'

      expect(last_response.status).to be(200)
    end
  end

  context 'sending' do
    it 'renders successfully' do
      get '/api/sms/us-short-codes/alerts/sending'

      expect(last_response.status).to be(200)
    end
  end

  context '2fa' do
    it 'renders successfully' do
      get '/api/sms/us-short-codes/2fa'

      expect(last_response.status).to be(200)
    end
  end
end
