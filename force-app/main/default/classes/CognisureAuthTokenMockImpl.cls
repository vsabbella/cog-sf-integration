/**
 * Created by venkatasabbella on 1/26/24.
 */

global class CognisureAuthTokenMockImpl implements HttpCalloutMock {
    //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(CognisureAPIRequestsTest.getAuthTokenResponse());
        res.setStatusCode(200);
        return res;
    }
}