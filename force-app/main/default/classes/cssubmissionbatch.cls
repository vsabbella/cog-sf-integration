public class cssubmissionbatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {


    class submissionException extends Exception {
    }
    String query;
    private CognisureAPIConsumerCtrl csapi;

    public cssubmissionbatch() {
        Sobject  cognisureapimetadata = [Select Id,Email_Message_Query_Plugin__c, Submission_Query_Plugin__c from Cognisureapi__mdt where DeveloperName ='api_details'];
        String submissionqueryplugin= cognisureapimetadata.get('Submission_Query_Plugin__c')!=null?(String)cognisureapimetadata.get('Submission_Query_Plugin__c'):'CognisureAPI.SubmissionQueryBuilder';
        this.query =  ((CognisureAPI.ISubmissionQueryHandler)Type.forName(submissionqueryplugin).newInstance()).getSubmissionQuery();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            this.csapi = new CognisureAPIConsumerCtrl();
            List<Sobject> sobjlist = new List<Sobject>();
            for (SObject sobj : scope) {
                String submissionId = (String) sobj.get('Message_Id__c');
                Id submissionSobjId = (Id) sobj.get('Id');
                String JSONRepsonse = this.csapi.getCommonJSONforSubmission(submissionId);
                System.debug(LoggingLevel.Debug, 'JSON Response' + JSONRepsonse);
                ProcessSubmissionResponse.processJSONResponse(JSONRepsonse, submissionSobjId);
                sobj.put('processed_commonjson__c', true);
                sobjlist.add(sobj);
            }
            update sobjlist;
        } catch (Exception Ex) {
            Throw new submissionException('' + Ex.getStackTraceString() + Ex.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC) {
        String jobName = 'Common JSON Processor Batch' + Datetime.now();
        if (!test.isRunningTest())
            system.scheduleBatch(this, jobName, 1);
    }
}