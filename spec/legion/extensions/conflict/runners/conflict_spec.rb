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

  describe '#check_stale_conflicts' do
    it 'returns zero stale when no conflicts exist' do
      result = client.check_stale_conflicts
      expect(result[:checked]).to eq(0)
      expect(result[:stale_count]).to eq(0)
      expect(result[:stale_ids]).to eq([])
    end

    it 'returns zero stale for recently created conflicts' do
      client.register_conflict(parties: %w[a b], severity: :low, description: 'fresh')
      result = client.check_stale_conflicts
      expect(result[:stale_count]).to eq(0)
    end

    it 'detects stale conflicts older than STALE_CONFLICT_TIMEOUT' do
      c = client.register_conflict(parties: %w[a b], severity: :medium, description: 'old')
      # Backdate the created_at timestamp
      conflict = client.instance_variable_get(:@conflict_log).conflicts[c[:conflict_id]]
      conflict[:created_at] = Time.now.utc - (Legion::Extensions::Conflict::Helpers::Severity::STALE_CONFLICT_TIMEOUT + 1)
      result = client.check_stale_conflicts
      expect(result[:stale_count]).to eq(1)
      expect(result[:stale_ids]).to include(c[:conflict_id])
    end

    it 'does not include resolved conflicts in stale check' do
      c = client.register_conflict(parties: %w[a b], severity: :low, description: 'resolved')
      conflict = client.instance_variable_get(:@conflict_log).conflicts[c[:conflict_id]]
      conflict[:created_at] = Time.now.utc - (Legion::Extensions::Conflict::Helpers::Severity::STALE_CONFLICT_TIMEOUT + 1)
      client.resolve_conflict(conflict_id: c[:conflict_id], outcome: :closed)
      result = client.check_stale_conflicts
      expect(result[:stale_count]).to eq(0)
    end
  end
end
