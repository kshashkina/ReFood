import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockSend } = vi.hoisted(() => ({
    mockSend: vi.fn()
}));

vi.mock('@aws-sdk/client-lambda', () => ({
    LambdaClient: function () { this.send = mockSend; },
    InvokeCommand: function (input) { this.input = input; }
}));

import { invokeMetrics } from '../services/metricsService.mjs';

describe('metricsService', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('invokeMetrics', () => {

        it('should not invoke if userId is missing', async () => {
            await invokeMetrics('scan_product', null);
            expect(mockSend).not.toHaveBeenCalled();
        });

        it('should invoke with correct action and userId', async () => {
            mockSend.mockResolvedValue({});
            await invokeMetrics('scan_product', 'user-123');

            const command = mockSend.mock.calls[0][0];
            const payload = JSON.parse(Buffer.from(command.input.Payload).toString());

            expect(payload.action).toBe('scan_product');
            expect(payload.userId).toBe('user-123');
        });
    });
});
