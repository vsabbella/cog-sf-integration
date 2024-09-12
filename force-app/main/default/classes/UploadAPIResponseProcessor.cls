public with sharing class UploadAPIResponseProcessor {
    public UploadAPIResponseProcessor() {

    }
    //force-app\main\default\classes\UploadAPIResponseProcessor.cls

    public static Sobject processJSONResponse(String JSONResponse){

        //StaticResource SR = [Select id,name,body from StaticResource where Name = 'uploadresponse'];
        String uploadresponse =  JSONResponse;
        System.debug(LoggingLevel.DEBUG, 'processJSONResponse:'+uploadresponse);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(uploadresponse);
        String response_Id = (String)m.get('id');

        return getSubmissionRecord(response_Id);
    }

    public static Sobject getSubmissionRecord(String messageId){
     Sobject sobj = getSobjectInstance('Submission__c');
     sobj.put('Custom_JSON_Status__c',false);
     sobj.put('Message_Id__c',messageId);
     sobj.put('Submission_360_Status__c',false);
     sobj.put('Submission_Id__c','');
     //Insert sobj;
     return sobj;
    }
    public static SObject getSobjectInstance(String sobjectName){
        Schema.DescribeSobjectResult[] dsrList = Schema.describeSObjects(new List<String>{sobjectName});
        Schema.DescribeSobjectResult dsr = dsrList[0];
        return dsr.getSObjectType().newSObject();

    }
}