/**
 * Created by venkatasabbella on 1/26/24.
 */


@isTest
global class CognisureFileUploadMockImpl implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        String reqendpointURL = req.getEndpoint().split('\\?')[0];//String.split(req.getEndpoint(),'?');
        System.assertEquals('https://api.cognisure.ai/api/submission/upload', reqendpointURL);
        System.assertEquals('POST', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(CognisureAPIRequestsTest.getFileUploadAPIResponse());
        res.setStatusCode(200);
        return res;
    }
}