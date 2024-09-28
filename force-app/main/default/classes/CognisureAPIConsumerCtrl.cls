/**
     *
     *
     *
     */

public with sharing class CognisureAPIConsumerCtrl {

    private final String namespacePrefix = CognisureAPI_Util.getNameSpacePrefix();

    private String commonjsonapiurl {
        get {
            return (String) cognisureapimetadata.get('Common_JSON_URL__c');
        }
        private set;
    }

    class CognisureAPIConsumerCtrlException extends Exception {
    }
    private sobject cognisureapimetadata {
        get {
            if (cognisureapimetadata == null) {
                cognisureapimetadata = (Sobject) Cognisureapi__mdt.getInstance('api_details');
                if (test.isRunningTest()) {
                }
                System.debug(LoggingLevel.DEBUG, JSON.serialize(cognisureapimetadata));
            }
            return cognisureapimetadata;
        }
        private set;
    }

    private String authurl {
        get {
            return (String) cognisureapimetadata.get('Token_URL__c');
        }
        private set;
    }
    private String baseurl {
        get {
            return (String) cognisureapimetadata.get('Base_URL__c');
        }
        private set;
    }
    private String uploadapiurl {
        get {
            return (String) cognisureapimetadata.get('Upload_API_Endpoint__c');
        }
        private set;
    }
    private String uploadapiimplementation {
        get {
            uploadapiimplementation = cognisureapimetadata.get('Upload_API_Plugin__c') != null ? (String) cognisureapimetadata.get('Upload_API_Plugin__c') : 'CognisureAPI.EmailAttachmentForm64';
            return uploadapiimplementation;
        }
        private set;
    }
    private String tokenresponsekey {
        get {
            return (String) cognisureapimetadata.get('Token_Response_Key__c');
        }
        private set;
    }
    private String username {
        get {
            return (String) cognisureapimetadata.get('Username__c');
        }
        private set;
    }

    private String password {
        get {
            return (String) cognisureapimetadata.get('Password__c');
        }
        private set;
    }
    private String NamedCredentail {
        get {
            if (NamedCredentail == null) {
                NamedCredentail = (String) cognisureapimetadata.get('NamedCredentail__c');
                NamedCredentail = this.namespacePrefix + NamedCredentail;
            }
            return NamedCredentail;
        }
        private set;
    }
    public CognisureAPIConsumerCtrl() {

    }

    private String ctoken {
        get {
            if (ctoken == null) {
                getAuthToken();
            }
            return ctoken;
        }
        private set;
    }

    private void getAuthToken() {
        // Instantiate a new Http object
        Http h = new Http();
        //String url = this.baseurl + this.authurl;

        String payload = 'grant_type=password&username=' + this.username + '&password=' + this.password;

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:' + this.NamedCredentail + this.authurl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(payload);

        HttpResponse res = h.send(req);
        Map<String, String> resMap = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);
        System.debug(LoggingLevel.Debug, '' + res.getBody());
        string responseStatusCode = String.valueof(res.getStatusCode());
        string responseBody = String.valueof(res.getbody());

        if (responseStatusCode == '401')
            throw new CognisureAPIConsumerCtrlException('Error:' + responseBody);
        this.ctoken = resMap.get(this.tokenresponsekey);
    }
    public String makeUploadRequestdo(String caseId) {

        if (test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new CognisureAuthTokenMockImpl());

        String ctoken2 = this.ctoken;
        if (string.isBlank(ctoken2))
            throw new CognisureAPIConsumerCtrlException('Invalid Token:null');

        if (String.isNotBlank(caseId)) {
            if (String.isNotBlank(this.NamedCredentail) && String.isNotBlank(this.uploadapiurl)) {

                Schema.DescribeSObjectResult[] descResult_submission = Schema.describeSObjects(new List<String>{
                        'Case'
                });
                Schema.DescribeSObjectResult descRes = descResult_submission[0].getSObjectType().getDescribe();
                if (descResult_submission[0].isAccessible() && descResult_submission[0].isQueryable()) {
                    String form64 = '';
                    //form64+= getBase64StringFromAttachments(caseId);
                    //form64+= getBase64StringFromAttachmentsUsingImpl(caseId);
                    //CognisureAPI.IBase64Handler ibase64impl = (CognisureAPI.IBase64Handler) Type.forName(this.uploadapiimplementation).newInstance();
                    String contentPlugin = (String) cognisureapimetadata.get('File_Content_Plugin__c');
                    String fileQueryClass = string.isBlank(contentPlugin) ? 'CognisureAPI.AttachmentQuery' : contentPlugin;
                    CognisureAPI.IFileContentQueryHander fileQueryHandler = (CognisureAPI.IFileContentQueryHander) Type.forName(fileQueryClass).newInstance();
                    String fileQueryString = fileQueryHandler.getFileContentQuery(caseId);
                    form64 += CognisureAPI_Util.getBase64String(caseId, fileQueryString);

                    string contentType = vNHttpFormBuilder.GetContentType();

                    blob formBlob = EncodingUtil.base64Decode(form64);
                    string contentLength = string.valueOf(formBlob.size());

                    //  Compose the http request
                    HttpRequest httpRequest = new HttpRequest();

                    httpRequest.setHeader('Authorization', 'Bearer ' + ctoken2);

                    //httpRequest.setBody(emailbodyjson);
                    String uploadAPIUrlformatted = String.format(this.uploadapiurl, new List<String>{
                            '', caseId, caseId
                    });
                    //string namedCredendpoint = 'callout:'+this.NamedCredentail+uploadAPIUrlStr;
                    //string namedCredendpoint_2 = 'callout:csfileupload'+uploadAPIUrlStr;
                    //System.debug(LoggingLevel.DEBUG,namedCredendpoint);
                    String endpoint = this.baseurl + uploadAPIUrlformatted;
                    httpRequest.setEndpoint(endpoint);
                    httpRequest.setHeader('Connection', 'keep-alive');
                    httpRequest.setHeader('Content-Length', contentLength);
                    httpRequest.setHeader('Content-Type', contentType);
                    httpRequest.setMethod('POST');
                    httpRequest.setTimeout(120000);
                    httpRequest.setBodyAsBlob(formBlob);

                    if (test.isRunningTest())
                        Test.setMock(HttpCalloutMock.class, new CognisureFileUploadMockImpl());

                    Http http = new Http();
                    HTTPResponse res = http.send(httpRequest);

                    string responseStatusCode = String.valueof(res.getStatusCode());
                    string responseBody = String.valueof(res.getbody());

                    if (responseStatusCode == '401')
                        throw new CognisureAPIConsumerCtrlException('Unauthorized response code:');

                    if (responseStatusCode != '200')
                        throw new CognisureAPIConsumerCtrlException('Callout Failed with response code :' + responseStatusCode);

                    System.debug(LoggingLevel.Debug, 'resp body' + responseBody);
                    System.debug(LoggingLevel.Debug, 'resp body' + responseStatusCode);
                    return responseBody;
                } else {
                    Throw New CognisureAPIConsumerCtrlException('You donot  enough permission to perform this action on Case object');
                }


            }
        } else
                Throw new CognisureAPIConsumerCtrlException('case Id is Empty');

        return null;

    }

    public String getCommonJSONforSubmission(String submissionId) {

        if (test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new CognisureAuthTokenMockImpl());
        String ctoken = this.ctoken;
        String commonJSONEndpoint = this.baseurl + this.commonjsonapiurl;
        commonJSONEndpoint = String.format(commonJSONEndpoint, new List<String>{
                submissionId
        });
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setHeader('Authorization', 'Bearer ' + ctoken);
        httpRequest.setEndpoint(commonJSONEndpoint);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setMethod('GET');

        if (test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new CognisureCommonJsonMockImpl());

        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);

        string responseStatusCode = String.valueof(res.getStatusCode());
        string responseBody = String.valueof(res.getbody());

        System.debug(LoggingLevel.Debug, 'resp Code' + responseStatusCode);
        System.debug(LoggingLevel.Debug, 'resp body' + responseBody);

        return responseBody;
    }


}