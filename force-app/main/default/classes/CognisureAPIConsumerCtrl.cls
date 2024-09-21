/**
     *
     *
     *
     */

public with sharing class CognisureAPIConsumerCtrl {

    private String commonjsonapiurl {
        get{
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
                uploadapiimplementation=cognisureapimetadata.get('Upload_API_Plugin__c')!=null?(String) cognisureapimetadata.get('Upload_API_Plugin__c'):'CognisureAPI.EmailAttachmentForm64';
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

        String payload = 'grant_type=password&username='+this.username+'&password='+this.password;

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:'+this.NamedCredentail+this.authurl);
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
    public String makeUploadRequestdo( String caseId) {

        if (test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new CognisureAuthTokenMockImpl());

        String ctoken2 = this.ctoken;
        if (string.isBlank(ctoken2))
            throw new CognisureAPIConsumerCtrlException('Invalid Token:null');

        if (String.isNotBlank(caseId)) {
            if (String.isNotBlank(this.NamedCredentail) && String.isNotBlank(this.uploadapiurl)) {

                String form64 = '';
                //form64+= getBase64StringFromAttachments(caseId);
                //form64+= getBase64StringFromAttachmentsUsingImpl(caseId);
                //CognisureAPI.IBase64Handler ibase64impl = (CognisureAPI.IBase64Handler) Type.forName(this.uploadapiimplementation).newInstance();
                String contentPlugin = (String) cognisureapimetadata.get('File_Content_Plugin__c');
                String fileQueryClass = string.isBlank(contentPlugin)?'CognisureAPI.AttachmentQuery':contentPlugin;
                CognisureAPI.IFileContentQueryHander fileQueryHandler = (CognisureAPI.IFileContentQueryHander)Type.forName(fileQueryClass).newInstance();
                String fileQueryString = fileQueryHandler.getFileContentQuery(caseId);
                form64 += CognisureAPI_Util.getBase64String(caseId,fileQueryString);

                string contentType = vNHttpFormBuilder.GetContentType();

                blob formBlob = EncodingUtil.base64Decode(form64);
                string contentLength = string.valueOf(formBlob.size());

                //  Compose the http request
                HttpRequest httpRequest = new HttpRequest();

                httpRequest.setHeader('Authorization', 'Bearer ' + ctoken2);
                httpRequest.setBodyAsBlob(formBlob);
                //httpRequest.setBody(emailbodyjson);
                String uploadAPIUrlformatted = String.format(this.uploadapiurl,new List<String>{'',caseId,caseId});
                //string namedCredendpoint = 'callout:'+this.NamedCredentail+uploadAPIUrlStr;
                //string namedCredendpoint_2 = 'callout:csfileupload'+uploadAPIUrlStr;
                //System.debug(LoggingLevel.DEBUG,namedCredendpoint);
                String endpoint = this.baseurl+uploadAPIUrlformatted;
                httpRequest.setEndpoint(endpoint);
                httpRequest.setHeader('Connection', 'keep-alive');
                httpRequest.setHeader('Content-Length', contentLength);
                httpRequest.setHeader('Content-Type', contentType);
                httpRequest.setMethod('POST');
                httpRequest.setTimeout(120000);

                if(test.isRunningTest())
                   Test.setMock(HttpCalloutMock.class, new CognisureFileUploadMockImpl());

                Http http = new Http();
                HTTPResponse res = http.send(httpRequest);

                string responseStatusCode = String.valueof(res.getStatusCode());
                string responseBody = String.valueof(res.getbody());

                if (responseStatusCode == '401')
                    throw new CognisureAPIConsumerCtrlException('Unauthorized response code:');

                if (responseStatusCode != '200')
                    throw new CognisureAPIConsumerCtrlException('Callout Failed with response code :'+ responseStatusCode);

                System.debug(LoggingLevel.Debug, 'resp body' + responseBody);
                System.debug(LoggingLevel.Debug, 'resp body' + responseStatusCode);
                return responseBody;
            }
        } else
                Throw new CognisureAPIConsumerCtrlException('case Id is Empty');

        return null;

    }

    public String getCommonJSONforSubmission( String submissionId) {

        if (test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new CognisureAuthTokenMockImpl());
        String ctoken = this.ctoken;
        String commonJSONEndpoint = this.baseurl+this.commonjsonapiurl;
        commonJSONEndpoint = String.format(commonJSONEndpoint,new List<String>{submissionId});

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

    private static SObject getMetadata() {
        String metadataJSON = '[\n' +
                '  {\n' +
                '    "Base_URL__c": "https://api.cognisure.ai",\n' +
                '    "DeveloperName": "api_details",\n' +
                '    "Id": "m0PHp0000004mUPMAY",\n' +
                '    "Label": "api-details",\n' +
                '    "Language": "en_US",\n' +
                '    "MasterLabel": "api-details",\n' +
                '    "NamespacePrefix": null,\n' +
                '    "Password__c": "{!$Credential.Cognisure.password}",\n' +
                '    "QualifiedApiName": "api_details",\n' +
                '    "Token_Response_Key__c": "access_token",\n' +
                '    "Token_URL__c": "/token",\n' +
                '    "Upload_API_Endpoint__c": "/api/submission/upload?id={0}&submissionName={1}",\n' +
                '    "Username__c": "{!$Credential.Cognisure.username}",\n' +
                '    "Common_JSON_URL__c": "/api/submission/commonjson/?id={0}",\n' +
                '    "Email_Message_Query_Plugin__c": "CognisureAPI.MessageQueryBuilder",\n' +
                '    "Submission_Query_Plugin__c": "CognisureAPI.SubmissionQueryBuilder",\n' +
                '    "Upload_API_Plugin__c": "CognisureAPI.EmailAttachmentForm64",\n' +
                '    "NamedCredentail__c": "cognisureai"\n' +
                '  }\n' +
                ']';
        List<Sobject> metadataList = (List<Cognisureapi__mdt>) JSON.deserialize(metadataJSON, List<Cognisureapi__mdt>.class);
        return metadataList[0];
    }


}