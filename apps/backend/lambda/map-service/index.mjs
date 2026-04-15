import { getRecyclingPoints } from './handlers/getRecyclingPoints.mjs';
import { getRoute } from './handlers/getRoute.mjs';
import { optionsResponse, response } from './helpers/response.mjs';

export const handler = async (event) => {
  const method = event.requestContext?.http?.method || event.httpMethod;
  const path = event.rawPath || event.path;

  if (method === 'OPTIONS') {
    return optionsResponse();
  }

  if (method === 'GET' && path.includes('locations')) {
    return await getRecyclingPoints(event);
  }

  if (method === 'GET' && path.includes('route')) {
    return await getRoute(event);
  }

  return response(404, {
    message: 'Not Found'
  });
};
