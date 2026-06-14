import { describe, it, expect, vi } from 'vitest';

vi.mock('crypto', () => ({
    randomUUID: vi.fn(() => 'mocked-uuid-1234')
}));

import { toUserDBModel } from '../mappers/userMapper.mjs';

describe('userMapper', () => {

    describe('toUserDBModel', () => {

        it('should use generated UUID as userId and mapping fields', () => {
            const result = toUserDBModel('device-abc', 'identity-xyz');

            expect(result.userId).toBe('mocked-uuid-1234');
            expect(result.deviceId).toBe('device-abc');
            expect(result.identityId).toBe('identity-xyz');
            expect(result.isPremium).toBe(false);
            expect(result.scansCount).toBe(0);
        });
    });
});
