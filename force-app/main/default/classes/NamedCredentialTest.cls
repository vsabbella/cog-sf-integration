//NamedCredentialTest.NamedCredentialTest();
public with sharing class NamedCredentialTest {
    public static void NamedCredentialTest() {


        String form64 = 'test';
        //form64+= getBase64StringFromAttachments(caseId);
        //form64+= getBase64StringFromAttachmentsUsingImpl(caseId);


        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        string contentType = vNHttpFormBuilder.GetContentType();
        //  Compose the http request
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setBodyAsBlob(formBlob);
        //httpRequest.setBody(emailbodyjson);
        String uploadAPIUrlformatted = String.format('/api/submission/upload?id={0}&submissionName={1}&X-Unique-Id={2}', new List<String>{
                '', 'caseId', 'caseId'
        });
        //string namedCredendpoint = 'callout:'+this.NamedCredentail+uploadAPIUrlStr;
        //string namedCredendpoint_2 = 'callout:csfileupload'+uploadAPIUrlStr;
        //System.debug(LoggingLevel.DEBUG,namedCredendpoint);
        //String endpoint = this.baseurl+uploadAPIUrlformatted;
        httpRequest.setEndpoint('callout:csundrwrtr__Cognisure_File_Upload' + uploadAPIUrlformatted);
        httpRequest.setHeader('Connection', 'keep-alive');
        //httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        //httpRequest.setHeader('Authorization', 'Bearer ' + 'pe8Au5CuKIlvWuaH53GDsfI1PetR-6_Ce-6oPgAR6VdJQvVjELkAZxy_8j16jDqKnVgS1yTSoFJXWxD0zjnoavxOi6af-XsVTvme6lAzS1dPZIAN88BroegFtau8hZD7tPVc6s0kat9tv__2Hft_a7AirSXKEJ9d_dcl5mfiQ4LjUlK4Tq6cGB2TFVmWDiARgKS2D0FUJ0Zoj_IlgrqvXTU8pZQiw16UtgePXhawfJmW_xS5kjZ-JNr3wMpYxAD5');

        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);

        string responseStatusCode = String.valueof(res.getStatusCode());
        string responseBody = String.valueof(res.getbody());

        //if (responseStatusCode == '401')
        //throw new CognisureAPIConsumerCtrlException('Unauthorized response code:');

        System.debug(LoggingLevel.Debug, 'resp body' + responseBody);
        System.debug(LoggingLevel.Debug, 'resp body' + responseStatusCode);
        //return responseBody;
    }
    //NamedCredentialTest.NamedCredentialTest();
    public static void callCognisure() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Cognisure_Password_Auth/api/submission/upload?id={0}&submissionName=Test&X-Unique-Id=Test');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Connection', 'keep-alive');
        req.setTimeout(120000);

        blob formBlob = EncodingUtil.base64Decode('This is Test');
        req.setBodyAsBlob(formBlob);
        Http http = new Http();
        System.debug(LoggingLevel.DEBUG, req.getHeader('Authorization'));
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());

    }
}