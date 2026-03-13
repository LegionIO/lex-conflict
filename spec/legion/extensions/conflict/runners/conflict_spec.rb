# frozen_string_literal: true

require 'legion/extensions/conflict/client'

RSpec.describe Legion::Extensions::Conflict::Runners::Conflict do
  let(:client) { Legion::Extensions::Conflict::Client.new }

  describe '#register_conflict' do
    it 'creates a conflict with recommended posture' do
      result = client.register_conflict(parties: %w[agent human], severity: :high, description: 'disagreement')
      expect(result[:conflict_id]).to match(/\A[0-9a-f-]{36}\z/)
      expect(result[:posture]).to eq(:persistent_engagement)
    end

    it 'recommends stubborn_presence for critical' do
      result = client.register_conflict(parties: %w[agent human], severity: :critical, description: 'safety issue')
      expect(result[:posture]).to eq(:stubborn_presence)
    end

    it 'rejects invalid severity' do
      result = client.register_conflict(parties: [], severity: :invalid, description: 'test')
      expect(result[:error]).to eq(:invalid_severity)
    end
  end

  describe '#add_exchange' do
    it 'records an exchange' do
      c = client.register_conflict(parties: %w[a b], severity: :medium, description: 'test')
      result = client.add_exchange(conflict_id: c[:conflict_id], speaker: 'a', message: 'I disagree')
      expect(result[:recorded]).to be true
    end
  end

  describe '#resolve_conflict' do
    it 'resolves a conflict' do
      c = client.register_conflict(parties: %w[a b], severity: :low, description: 'test')
      result = client.resolve_conflict(conflict_id: c[:conflict_id], outcome: :compromise)
      expect(result[:resolved]).to be true
    end
  end

  describe '#active_conflicts' do
    it 'lists active conflicts' do
      client.register_conflict(parties: %w[a b], severity: :low, description: 'test')
      result = client.active_conflicts
      expect(result[:count]).to eq(1)
    end
  end

  describe '#recommended_posture' do
    it 'returns posture for severity' do
      result = client.recommended_posture(severity: :critical)
      expect(result[:posture]).to eq(:stubborn_presence)
    end
  end
end
