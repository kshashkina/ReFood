import { describe, it, expect, vi, beforeEach } from 'vitest';

const { mockSendToDb } = vi.hoisted(() => ({
    mockSendToDb: vi.fn()
}));

vi.mock('@aws-sdk/client-dynamodb', () => ({
    DynamoDBClient: function () { }
}));

vi.mock('@aws-sdk/lib-dynamodb', () => ({
    DynamoDBDocumentClient: {
        from: vi.fn().mockReturnValue({ send: mockSendToDb })
    },
    GetCommand: function (input) { this.input = input; },
    UpdateCommand: function (input) { this.input = input; },
    DeleteCommand: function (input) { this.input = input; }
}));

import { getMetrics, incrementScanned, incrementSorted, updateStreak, trackMapCheck, incrementAddedProducts, deleteMetrics } from '../services/userMetricsDatabase.mjs';

describe('userMetricsDatabase', () => {

    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('getMetrics - fetching user metrics', () => {

        it('should return item if found in DB', async () => {
            const fakeMetrics = { userId: 'user-1', scannedCount: 5 };
            mockSendToDb.mockResolvedValue({ Item: fakeMetrics });

            const result = await getMetrics('user-1');

            expect(result).toEqual(fakeMetrics);
        });

        it('should return null if item not found', async () => {
            mockSendToDb.mockResolvedValue({});

            const result = await getMetrics('user-unknown');

            expect(result).toBeNull();
        });

        it('should throw error if DynamoDB is unavailable', async () => {
            mockSendToDb.mockRejectedValue(new Error('DynamoDB unavailable'));

            await expect(getMetrics('user-1')).rejects.toThrow('DynamoDB unavailable');
        });
    });

    describe('incrementScanned - incrementing scanned items count', () => {

        it('should create user metrics if not exists and increment scannedCount', async () => {
            mockSendToDb.mockResolvedValue({});

            await incrementScanned('user-1', { hour: 12, isWeekend: false });

            expect(mockSendToDb).toHaveBeenCalledTimes(1);

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).toContain('scannedCount');
        });

        it('should include earlyBirdUnlocked in expression if hour < 9', async () => {
            mockSendToDb.mockResolvedValue({});

            await incrementScanned('user-1', { hour: 7, isWeekend: false });

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).toContain('earlyBirdUnlocked');
        });

        it('should NOT include earlyBirdUnlocked if hour >= 9', async () => {
            mockSendToDb.mockResolvedValue({});

            await incrementScanned('user-1', { hour: 10, isWeekend: false });

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).not.toContain('earlyBirdUnlocked');
        });

        it('should include weekendHasScanned if isWeekend=true', async () => {
            mockSendToDb.mockResolvedValue({});

            await incrementScanned('user-1', { hour: 12, isWeekend: true });

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).toContain('weekendHasScanned');
        });

        it('should set ecoWeekendUnlocked if both scan and map done on weekend', async () => {
            mockSendToDb
                .mockResolvedValueOnce({})
                .mockResolvedValueOnce({ Item: { weekendHasScanned: true, weekendHasMapped: true, ecoWeekendUnlocked: false } })
                .mockResolvedValueOnce({});

            await incrementScanned('user-1', { hour: 12, isWeekend: true });

            const calledWith = mockSendToDb.mock.calls[2][0];
            expect(calledWith.input.UpdateExpression).toContain('ecoWeekendUnlocked');
        });
    });

    describe('incrementSorted - incrementing sorted items count', () => {

        it('should create user metrics if not exists and increment sortedCount', async () => {
            mockSendToDb.mockResolvedValue({});

            await incrementSorted('user-1');

            expect(mockSendToDb).toHaveBeenCalledTimes(1);

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).toContain('sortedCount');
        });
    });

    describe('trackMapCheck', () => {

        it('should include ninjaSortingUnlocked if hour >= 20', async () => {
            mockSendToDb.mockResolvedValue({});

            await trackMapCheck('user-1', { hour: 21, isWeekend: false });

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).toContain('ninjaSortingUnlocked');
        });

        it('should include ninjaSortingUnlocked if isWeekend=true', async () => {
            mockSendToDb.mockResolvedValue({});
            mockSendToDb.mockResolvedValueOnce({}).mockResolvedValueOnce({});

            await trackMapCheck('user-1', { hour: 12, isWeekend: true });

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).toContain('ninjaSortingUnlocked');
        });

        it('should not include ninjaSortingUnlocked during regular hours on weekday', async () => {
            mockSendToDb.mockResolvedValue({});

            await trackMapCheck('user-1', { hour: 13, isWeekend: false });

            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).not.toContain('ninjaSortingUnlocked');
        });
    });

    describe('updateStreak', () => {

        it('should initialize streak=1 if no existing metrics', async () => {
            mockSendToDb
                .mockResolvedValueOnce({})
                .mockResolvedValueOnce({});

            await updateStreak('user-1');

            const updateCall = mockSendToDb.mock.calls[1][0];
            expect(updateCall.input.UpdateExpression).toContain('streakDays');
        });

        it('should increment streak if opened on the next day', async () => {
            const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
            mockSendToDb
                .mockResolvedValueOnce({ Item: { lastOpenedDate: yesterday } })
                .mockResolvedValueOnce({});

            await updateStreak('user-1');

            const updateCall = mockSendToDb.mock.calls[1][0];
            expect(updateCall.input.UpdateExpression).toContain('ADD streakDays');
        });
    });

    describe('incrementAddedProducts', () => {

        it('should call DB once with ADD expression', async () => {
            mockSendToDb.mockResolvedValue({});

            await incrementAddedProducts('user-1');

            expect(mockSendToDb).toHaveBeenCalledTimes(1);
            const calledWith = mockSendToDb.mock.calls[0][0];
            expect(calledWith.input.UpdateExpression).toContain('addedProductsCount');
        });

    });

    describe('deleteMetrics', () => {

        it('should call DB once for delete', async () => {
            mockSendToDb.mockResolvedValue({});

            await deleteMetrics('user-1');

            expect(mockSendToDb).toHaveBeenCalledTimes(1);
        });
    });
});
