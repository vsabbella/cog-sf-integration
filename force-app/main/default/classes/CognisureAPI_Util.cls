/**
 * Author : vsabbella
 */
public with sharing class CognisureAPI_Util {

    private with sharing class CognisureAPIException extends Exception {
    }
    private static String NAMESPACEPREFIX {
        get {
            if (NAMESPACEPREFIX == null) {
                Schema.DescribeSObjectResult dsr = Cognisureapi__mdt.sObjectType.getDescribe();
                NAMESPACEPREFIX = dsr.getName().remove(dsr.getLocalName());
                System.debug(LoggingLevel.DEBUG, NAMESPACEPREFIX);

            }
            return NAMESPACEPREFIX;
        }
        private set;
    }

    public Static String getNameSpacePrefix() {
        return NAMESPACEPREFIX;
    }


    public Static String getSubmissionId() {
        System.debug(LoggingLevel.DEBUG, 'Submission Id from metadata' + (String) cognisureapimetadata.get('Submission_Id__c'));
        String submissionId0 = cognisureapimetadata.get('Submission_Id__c') != null ? (String) cognisureapimetadata.get('Submission_Id__c') : '';
        return submissionId0;
    }

    private static sobject cognisureapimetadata {
        get {
            if (cognisureapimetadata == null) {
                cognisureapimetadata = getcognisureapimetadata();
            }
            return cognisureapimetadata;
        }
        private set;
    }

    public Static String getMessageQuery() {
        return 'Select Id from case where createdDate = today and Id not in (select case__c from Submission__c)';
    }

    public Static String getSubmissionQuery() {
        return 'Select Id,name,Message_Id__c,processed_commonjson__c from Submission__c where CreatedDate =Today and  Common_JSON_Status__c =true and processed_commonjson__c=false and Message_Id__c!=null order by LastModifiedDate desc';
    }

    public static void overwriteSObjectFieldValues(SObjectType sObjectType, List<SObject> records) {
        if (sObjectType == CustomerProperty.SObjectType) {
            System.debug(LoggingLevel.ERROR, 'Processing Sobject Type' + sObjectType);
            Id rtId;
            for (sobject s : records) {

            }
        } else if (sObjectType == Claim.SObjectType) {

        } else if (sObjectType == InsurancePolicy.SObjectType) {
            //List<Product2> prods = [select id, name from product2 where IsActive = true limit 1];
            //Id prodId;
            //if (prods.size() > 0) {
            //    prodId = prods[0].Id;
            //}
            //for (sobject s : records) {
            //if (!string.isBlank(prodId)) {
            //s.put('ProductId',prodId);
            //}

            //}
        }
    }


    public Static string getBase64String(String caseId, String fileQueryString) {

        System.debug(LoggingLevel.DEBUG, 'From EmailAttachmentForm64');
        String form64 = '';
        vNHttpFormBuilder.WriteFileResult result;

        for (Sobject sobj : Database.query(fileQueryString)) {
            blob blobcontent;
            String fileContentField;
            fileContentField = sobj.getSObjectType().toString() == 'ContentVersion' ? 'VersionData' : 'Body';// read from contentvesion or attachment.
            blobcontent = (blob) sobj.get(fileContentField);
            String file64Encoded = EncodingUtil.base64Encode(blobcontent);
            form64 += vNHttpFormBuilder.WriteBoundary();
            System.Debug(LoggingLevel.Debug, 'first line');
            System.Debug(LoggingLevel.Debug, form64);
            String titleField = sobj.getSObjectType().toString() == 'ContentVersion' ? 'Title' : 'Name';
            String title = (String) sobj.get(titleField);
            form64 += vNHttpFormBuilder.WriteBodyParameter('file', title + '.pdf');
            System.Debug(LoggingLevel.Debug, 'after parameter');
            System.Debug(LoggingLevel.Debug, form64);
            form64 += vNHttpFormBuilder.WriteBoundary();

            result = vNHttpFormBuilder.WriteFile('file', title + '.pdf', 'application/octet-stream', blobcontent);
            form64 += result.Content;
        }

        if (string.isBlank(form64)) {
            Throw New CognisureAPIException('Content not read from either files or attachments. Files/Attachemnts does not exist on case.');
        }

        String SObjectTypeStr_EmailMessage = 'EmailMessage';
        //Schema.DescribeSObjectResult[] descResult_email = Schema.describeSObjects(new List<String>{
          //      SObjectTypeStr_EmailMessage
        //});
        //Schema.DescribeSObjectResult descResEmailMessage = descResult_email[0].getSObjectType().getDescribe();
        
        
        if (EmailMessage.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.EmailMessage.fields.htmlbody.isAccessible()) {
            //Schema.SobjectField descRes_htmlbody = descResEmailMessage.fields.getMap().get('htmlbody');
            //Schema.DescribeFieldResult dfr_htmlbody = descRes_htmlbody.getDescribe();
            //if () {}
            //Id caseId2 = String.escapeSingleQuotes(caseId);
            for (EmailMessage em : [SELECT Id, htmlbody FROM EmailMessage WHERE ParentId = :caseId order by createdDate desc limit 1]) {
                    System.debug(LoggingLevel.DEBUG, 'Attaching email body');
                    String emailbodyjson;
                    emailbodyjson = '{"emailbody":""+' + em.htmlbody + '}';
                    form64 += vNHttpFormBuilder.WriteBoundary();
                    System.Debug(LoggingLevel.Debug, 'first line');
                    System.Debug(LoggingLevel.Debug, form64);
                    form64 += vNHttpFormBuilder.WriteBodyParameter('file', em.HtmlBody + '.json');
                    System.Debug(LoggingLevel.Debug, 'after parameter');
                    System.Debug(LoggingLevel.Debug, form64);
                    form64 += vNHttpFormBuilder.WriteBoundary();
                }
            
        } else {
            Throw New CognisureAPIException('You donot have permission to perform this action on ' + SObjectTypeStr_EmailMessage);
        }

        form64 += vNHttpFormBuilder.WriteBoundary(result.EndingType);
        return form64;
    }

    public static sobject getcognisureapimetadata() {
        sobject cognisureapimetadata = (Sobject) Cognisureapi__mdt.getInstance('api_details');
        return cognisureapimetadata;
    }


    public static String getAttachmentQuery(String sobjId) {
        Id caseId = Id.valueOf(sobjId);
        return 'SELECT id,name,body FROM Attachment WHERE ParentId IN (SELECT Id FROM EmailMessage WHERE ParentId = \'' + caseId + '\')';
    }

    public static String getContentVersionQuery(String sobjId) {
        Id caseId = Id.valueOf(sobjId);
        return 'SELECT Id, Title ,VersionData, ContentDocument.LatestPublishedVersion.FirstPublishLocationId ,ContentBodyId,FirstPublishLocationId  from  ContentVersion where FirstPublishLocationId In (Select Id from EmailMessage where ParentId In (\'' + caseId + '\'))';
    }

    public static void schedulebatchjobs() {
        CSFileUploadAPIConsumerBatch csfileupload = new CSFileUploadAPIConsumerBatch();
        database.executebatch(csfileupload, 1);


        cssubmissionbatch b = new cssubmissionbatch();
        database.executeBatch(b, 1);
    }


}