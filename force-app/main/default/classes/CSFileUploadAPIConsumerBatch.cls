public class CSFileUploadAPIConsumerBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    class CSFileUploadAPIException extends Exception {
    }
    String query;
    private CognisureAPIConsumerCtrl csapi;

    public CSFileUploadAPIConsumerBatch() {
       // this.query = 'Select Id from case where createdDate = today and Id not in (select case__c from Submission__c)';
        Sobject  cognisureapimetadata = [Select Id,Email_Message_Query_Plugin__c, Submission_Query_Plugin__c from Cognisureapi__mdt where DeveloperName ='api_details'];
        string fileuploadQueryPlugin = cognisureapimetadata.get('Email_Message_Query_Plugin__c')!=null?(String)cognisureapimetadata.get('Email_Message_Query_Plugin__c'):'CognisureAPI.MessageQueryBuilder';
        this.query = ((CognisureAPI.IMessageQueryHandler )Type.forName(fileuploadQueryPlugin).newInstance()).getMessageQuery();

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            this.csapi = new CognisureAPIConsumerCtrl();
            List<Sobject> sobjlist = new List<Sobject>();
            for (SObject sobj : scope) {
                String sobjectId = (String) sobj.get('Id');

                String JSONResp = this.csapi.makeUploadRequestdo(sobjectId);
                System.debug(LoggingLevel.DEBUG, 'JSONResp:' + JSONResp);

                if(String.isBlank(JSONResp))
                    Throw New CSFileUploadAPIException('Empty Response from Server for File Upload');

                Sobject sobj_Submission = UploadAPIResponseProcessor.processJSONResponse(JSONResp);
                sobj_Submission.put('case__c', sobjectId);
                sobjlist.add(sobj_Submission);
                System.debug(LoggingLevel.DEBUG, JSON.serialize(sobjlist));
            }
            Insert sobjlist;
        } catch (Exception Ex) {
            Throw new CSFileUploadAPIException('Error Occured' + Ex.getStackTraceString() + Ex.getMessage());
        }
    }


    public void finish(Database.BatchableContext BC) {
        String jobName = 'File Upload Batch :' + Datetime.now();
        if (!test.isRunningTest())
            system.scheduleBatch(this, jobName, 1);

    }
}

/**
 *
 *
 *
 *
 *
  CSFileUploadAPIConsumerBatch cs = new CSFileUploadAPIConsumerBatch();
  Database.executeBatch(cs, 1);



 *
 *
 */