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

    it('should not call Lambda if userId is missing', async () => {
        await invokeMetrics('scan_product', null);
        await invokeMetrics('scan_product', undefined);

        expect(mockSend).not.toHaveBeenCalled();
    });

    it('should invoke Lambda with correct action and userId', async () => {
        mockSend.mockResolvedValue({});

        await invokeMetrics('scan_product', 'user-123');

        expect(mockSend).toHaveBeenCalledTimes(1);

        const command = mockSend.mock.calls[0][0];
        const payload = JSON.parse(Buffer.from(command.input.Payload).toString());

        expect(payload.action).toBe('scan_product');
        expect(payload.userId).toBe('user-123');
    });

    it('should throw if Lambda invoke fails', async () => {
        mockSend.mockRejectedValue(new Error('Lambda unavailable'));

        await expect(invokeMetrics('scan_product', 'user-123')).rejects.toThrow('Lambda unavailable');
    });
});
