/**
 * Created by venkatasabbella on 1/27/24.
 */

global with sharing class CognisureCommonJsonMockImpl implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(CognisureAPIRequestsTest.getCommonjsonAPIResp2());
        res.setStatusCode(200);
        return res;
    }
}