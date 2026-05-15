export const getRequestIdentity = (event) => {
    const jwtSub = event.requestContext.authorizer?.claims?.sub || event.requestContext.authorizer?.jwt?.claims?.sub;

    if (jwtSub) {
        return { type: 'jwt', id: jwtSub };
    }

    const identityId = event.requestContext.identity?.cognitoIdentityId;

    if (identityId) {
        return { type: 'identityId', id: identityId };
    }

    const mockIdentityId = event.headers?.['x-mock-identity-id'];
    if (mockIdentityId) return { type: 'identityId', id: mockIdentityId };

    return null;
};
