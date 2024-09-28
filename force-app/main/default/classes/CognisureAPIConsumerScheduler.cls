global with sharing class CognisureAPIConsumerScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        CSFileUploadAPIConsumerBatch csfileupload = new CSFileUploadAPIConsumerBatch();
        database.executebatch(csfileupload, 1);


        cssubmissionbatch b = new cssubmissionbatch();
        database.executeBatch(b, 1);


    }
}