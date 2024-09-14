Global with sharing class CognisureAPI {

    public class CognisureAPIException extends Exception{}
    
    private static sobject cognisureapimetadata {
        get {
            if (cognisureapimetadata == null) {
                cognisureapimetadata = (Sobject) Cognisureapi__mdt.getInstance('api_details');
                if (test.isRunningTest()) {
                    //cognisureapimetadata = getMetadata();
                }
            }
            return cognisureapimetadata;
        }
        private set;
    }
    
    global interface IBase64Handler{
        String getBase64String(String caseId);
    }

    global interface CommonJSONResponseHandler{
        void overwriteSObjectFieldValues(SObjectType sobjType, List<SObject> SobjList);
    }

    global interface IMessageQueryHandler{
        String getMessageQuery();
    }

    global interface ISubmissionQueryHandler{
        String getSubmissionQuery();
    }

    public class MessageQueryBuilder implements IMessageQueryHandler{
        public String getMessageQuery(){
            return 'Select Id from case where createdDate = today and Id not in (select case__c from Submission__c)';
        }
    }

    public class SubmissionQueryBuilder implements ISubmissionQueryHandler{
        public String getSubmissionQuery(){
            return 'Select Id,name,Message_Id__c,processed_commonjson__c from Submission__c where CreatedDate =Today and  Common_JSON_Status__c =true and processed_commonjson__c=false and Message_Id__c!=null order by LastModifiedDate desc';
        }
    }
    
    public class EmailAttachmentForm64 implements IBase64Handler{

        public string getBase64String(String caseId){

            System.debug(LoggingLevel.DEBUG,'From EmailAttachmentForm64');
            String form64 = '';
            vNHttpFormBuilder.WriteFileResult result;
            for(Attachment att: [SELECT id,name,body FROM Attachment WHERE ParentId IN (SELECT Id FROM EmailMessage WHERE ParentId = :caseId)]){
                blob blobcontent;
                String file64Encoded = EncodingUtil.base64Encode(att.body);//string
                blobcontent = EncodingUtil.base64Decode(file64Encoded);
    
                form64 += vNHttpFormBuilder.WriteBoundary();
                System.Debug(LoggingLevel.Debug,'first line');
                System.Debug(LoggingLevel.Debug,form64);
                form64 += vNHttpFormBuilder.WriteBodyParameter('file', att.name+'.pdf');
                System.Debug(LoggingLevel.Debug,'after parameter');
                System.Debug(LoggingLevel.Debug,form64);
                form64 += vNHttpFormBuilder.WriteBoundary();
    
                result = vNHttpFormBuilder.WriteFile('file', att.name+'.pdf', 'application/octet-stream', blobcontent);
                form64 += result.Content;
            }


            for(EmailMessage em:[SELECT Id,htmlbody FROM EmailMessage WHERE ParentId = :caseId order by createdDate desc limit 1]){
                System.debug(LoggingLevel.DEBUG,'Attaching email body');
                String emailbodyjson;
                emailbodyjson = '{"emailbody":""+'+em.htmlbody+'}';
                form64 += vNHttpFormBuilder.WriteBoundary();
                System.Debug(LoggingLevel.Debug,'first line');
                System.Debug(LoggingLevel.Debug,form64);
                form64 += vNHttpFormBuilder.WriteBodyParameter('file', em.HtmlBody+'.json');
                System.Debug(LoggingLevel.Debug,'after parameter');
                System.Debug(LoggingLevel.Debug,form64);
                form64 += vNHttpFormBuilder.WriteBoundary();
            }

            form64 += vNHttpFormBuilder.WriteBoundary(result.EndingType);
            return form64;
        }
    }

    public class sobjectrecordsinterceptor implements CommonJSONResponseHandler{
        public void overwriteSObjectFieldValues(SObjectType sObjectType, List<SObject> records){
            if(sObjectType==CustomerProperty.SObjectType){
                System.debug(LoggingLevel.ERROR, 'Processing Sobject Type'+sObjectType);
                Id rtId;
                //default record type to home type
                /*for(RecordType rt : [Select Id,name,DeveloperName from RecordType where SobjectType = 'customerproperty']){
                    if(rt.DeveloperName=='Home_Type'){
                        rtId = rt.Id;
                    }
                }*/

               for(sobject s:records){
                   s.put('YearBuilt',2010);
                   if(!string.isBlank(rtId)){
                     //s.put('RecordTypeId',rtId);
                   }
               }
            }
            else if(sObjectType==Claim.SObjectType){

            }
            else if(sObjectType==InsurancePolicy.SObjectType){
                List<Product2> prods= [select id,name from product2 where IsActive=true limit 1];
                Id prodId;
                if(prods.size()>0){
                    prodId = prods[0].Id;
                }
                for(sobject s:records){
                    if(!string.isBlank(prodId)){
                        //s.put('ProductId',prodId);
                    }

                }
            }
        }
    }
    //csundrwrtr.CognisureAPI.invokeLoadFromStaticResource('');
    //CognisureAPI.invokeLoadFromStaticResource('a1yHp0000090wZNIAY');
    global static void invokeLoadFromStaticResource(String SubmissionId){
        StaticResource SR = [Select id,name,body from StaticResource where Name = 'submissionrespunformatted'];//cognisureapimetadata.get
        String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        Delete [Select Id,name from Account where createdDate =Today];
        Delete [Select Id,name,ActualAmount,AssessmentDate,LossDate,Status from Claim ];
        Delete [Select Id,name,Address,format(createdDate), AnnualMileage, BuiltUpArea, CeilingType, City, ConstructionClass, Country  from CustomerProperty  ];
        Delete [Select Id,name from WorkerCompCoverageClass  ];
        Delete [Select Id,name from CoverageType  ];
        Delete [Select Id,name from Account where createdDate =Today];
        Delete [Select Id,name,ActualAmount,AssessmentDate,LossDate,Status from Claim ];
        
        String submissionId0;
        submissionId0 = SubmissionId;
        System.debug(LoggingLevel.DEBUG,'Submission Id from metadata'+(String)cognisureapimetadata.get('Submission_Id__c'));
        if(string.isBlank(submissionId0)){
            submissionId0 = cognisureapimetadata.get('Submission_Id__c')!=null?(String)cognisureapimetadata.get('Submission_Id__c'):'';
            
        }

        if(string.isBlank(submissionId0)){
            Throw New CognisureAPIException('Submission Id is empty');
        }

        ProcessSubmissionResponse.processJSONResponse(submissionResponseJson,submissionId0);
    }
    //CognisureAPI.schedulebatchjobs();
    global static void schedulebatchjobs(){
        CSFileUploadAPIConsumerBatch csfileupload = new CSFileUploadAPIConsumerBatch();
        database.executebatch(csfileupload,1);


        cssubmissionbatch b = new cssubmissionbatch();
        database.executeBatch(b,1);
    }


    /*public class LightningFileForm64Builder implements IBase64Handler{

        public string getBase64String(String caseId){
            blob blobcontent;
            String form64 = '';
            vNHttpFormBuilder.WriteFileResult result;
            for(Attachment att: [SELECT id,name,body FROM Attachment WHERE ParentId IN (SELECT Id FROM EmailMessage WHERE ParentId = :caseId)]){
                String file64Encoded = EncodingUtil.base64Encode(att.body);//string
                blobcontent = EncodingUtil.base64Decode(file64Encoded);

                form64 += vNHttpFormBuilder.WriteBoundary();
                System.Debug(LoggingLevel.Debug,'first line');
                System.Debug(LoggingLevel.Debug,form64);
                form64 += vNHttpFormBuilder.WriteBodyParameter('file', att.name+'.pdf');
                System.Debug(LoggingLevel.Debug,'after parameter');
                System.Debug(LoggingLevel.Debug,form64);
                form64 += vNHttpFormBuilder.WriteBoundary();

                result = vNHttpFormBuilder.WriteFile('file', att.name+'.pdf', 'application/octet-stream', blobcontent);
                form64 += result.Content;
            }
            form64 += vNHttpFormBuilder.WriteBoundary(result.EndingType);
            return form64;
        }
    }*/



}