global with sharing class CognisureAPI {

    public class CognisureAPIException extends Exception {
    }

    global interface IBase64Handler {
        String getBase64String(String caseId);
    }

    global interface IFileContentQueryHander {
        String getFileContentQuery(String caseId);
    }

    global interface CommonJSONResponseHandler {
        void overwriteSObjectFieldValues(SObjectType sobjType, List<SObject> SobjList);
    }

    global interface IMessageQueryHandler {
        String getMessageQuery();
    }

    global interface ISubmissionQueryHandler {
        String getSubmissionQuery();
    }

    public class MessageQueryBuilder implements IMessageQueryHandler {
        public String getMessageQuery() {
            return CognisureAPI_Util.getMessageQuery();
        }
    }

    public class SubmissionQueryBuilder implements ISubmissionQueryHandler {

        public String getSubmissionQuery() {
            return CognisureAPI_Util.getSubmissionQuery();
        }


    }

    public class AttachmentQuery implements CognisureAPI.IFileContentQueryHander {

        public string getFileContentQuery(String caseId) {
            return CognisureAPI_Util.getAttachmentQuery(caseId);
        }
    }

    public class LightningFileQuery implements CognisureAPI.IFileContentQueryHander {
        public string getFileContentQuery(String caseId) {
            return CognisureAPI_Util.getContentVersionQuery(caseId);
        }

    }

    public class sobjectrecordsinterceptor implements CommonJSONResponseHandler {
        public void overwriteSObjectFieldValues(SObjectType sObjectType, List<SObject> records) {
            CognisureAPI_Util.overwriteSObjectFieldValues(sObjectType, records);
        }
    }


    global static void schedulebatchjobs() {
        CognisureAPI_Util.schedulebatchjobs();
    }


}