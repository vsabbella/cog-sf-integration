/**
 * Created by venkatasabbella on 1/27/24.
 */

@isTest(SeeAllData=false)
private with sharing class CognisureAPIConsumerCtrlTest {

    private static testMethod void TestUploadPIRequests() {
        Sobject s = getMetadata();
        Case case0 = [select Id from case order by createdDate desc limit 1];
        Test.startTest();
        CognisureAPIConsumerCtrl c = new CognisureAPIConsumerCtrl();
        c.makeUploadRequestdo( case0.Id);
        Test.stopTest();

        /*
         CognisureAPIConsumerCtrl c = new CognisureAPIConsumerCtrl();
         Case case0 = [select Id from case order by createdDate desc limit 1];
         c.makeUploadRequestdo(token, '500Hp00001fQg3LIAS');
         */

/*
         CognisureAPIConsumerCtrl c = new CognisureAPIConsumerCtrl();
         c.getCommonJSONforSubmission(token, '60f392d8-2368-4963-93ae-a3eae529b8b3');

*/


    }

    private static testMethod void testCSFileUPloadBatch() {
        Id jobId ;
        Test.startTest();
        CSFileUploadAPIConsumerBatch c = new CSFileUploadAPIConsumerBatch();
        jobId = Database.executeBatch(c, 1);


        Test.stopTest();

        AsyncApexJob a = [Select Id, Status, ExtendedStatus, NumberOfErrors from AsyncApexJob where Id = :jobId];
        System.debug(LoggingLevel.DEBUG, 'AsyncApexJob' + a);
        Submission__c sub = [Select Id, name, Message_Id__c, Common_JSON_Status__c, Custom_JSON_Status__c, Submission_360_Status__c from Submission__c limit 1];
        system.assert(sub != null, 'Submission is null');
        //system.assert(sub.Message_Id__c!=null, 'Submission is null');
    }

    private static testMethod void testCSSubmissionBatch() {
        List<Claim> claims = [Select Id, name from Claim];
        system.assert(claims.size() == 0, 'Claims should not exist');
        Id jobId ;
        String respId = getMessageIdfromCSResponse();
        Submission__c s = [Select Id, name, Message_Id__c,Common_JSON_Status__c,processed_commonjson__c from Submission__c limit 1];
        s.Message_Id__c = respId;
        s.Common_JSON_Status__c = true;
        s.processed_commonjson__c = false;
        Update s;

        Test.startTest();
        cssubmissionbatch c = new cssubmissionbatch();
        jobId = Database.executeBatch(c, 1);
        Test.stopTest();

        AsyncApexJob a = [Select Id, Status, ExtendedStatus, NumberOfErrors from AsyncApexJob where Id = :jobId];
        System.assert(a.Status == 'Completed', 'AsyncApexJob' + a);
        System.assert(a.NumberOfErrors == 0, 'AsyncApexJob' + a);
        Submission__c sub = [Select Id, name, Message_Id__c, Common_JSON_Status__c, Custom_JSON_Status__c, Submission_360_Status__c from Submission__c limit 1];
        system.assert(sub != null, 'Submission is null');
        system.assert(sub.Message_Id__c != null, 'Submission is null');

        claims = [Select Id, name from Claim];
        system.assert(claims.size() > 0, 'Claims are not generated');
        system.debug(LoggingLevel.DEBUG, '' + claims);

    }

    private static testMethod void TestCommonJSONResponse() {
        Sobject s = getMetadata();
        //Sobject cognisureapimetadata = (Sobject)Cognisureapi__mdt.getInstance('api-details');
        //System.assert(cognisureapimetadata!=null, 'cognisureapimetadata is not found.');
        Case case0 = [select Id from case limit 1];
        Test.startTest();
        CognisureAPIConsumerCtrl c = new CognisureAPIConsumerCtrl();
        c.getCommonJSONforSubmission(case0.Id);
        Test.stopTest();
    }

    private static testMethod void TestScheduler() {
        CognisureAPIConsumerScheduler schInstance = new CognisureAPIConsumerScheduler();
        String sch ='0 48 * * * ?';
        System.schedule('Scheduler of API batches', sch,schInstance);
    }

    private static testMethod void test_ProcessJSONResponseFromStaticResource(){


        Test.startTest();
        try{
            CognisureAPIRequestsTest.test_ProcessJSONResponseFromStaticResource();
        }
        catch(Exception Ex){

        }
        Test.stopTest();
    }

    private static testMethod void testGlobalMethod_invokeLoadFromStaticResource(){
        List<Submission__c> submisstionList = [Select Id,name from Submission__c limit 1];
        System.assert(submisstionList.size()>0, 'Submission Record Does not Exist');
        String SubmisisonId = submisstionList[0].Id;
        Test.startTest();
        CognisureAPI.invokeLoadFromStaticResource(SubmisisonId);
        try{
            //CognisureAPI.invokeLoadFromStaticResource('a00DS00000Bz1m6YAB');
        }
        catch(Exception Ex){

        }
        List<Account> AcctList = [Select Id,name,RecordTypeId from Account where createdDate = Today];
        System.assert(AcctList.size()>0, 'Account Not created');
        System.Debug(LoggingLevel.DEBUG,'Accounts:'+JSON.serialize(AcctList));



        List<Claim> Claims = [Select Id,AccountId,IsDrivable,Status  from Claim where createdDate = Today];
        System.assert(Claims.size()>0, 'Claims Not created');
        System.Debug(LoggingLevel.DEBUG,'Claims:'+JSON.serialize(Claims));

        List<CustomerProperty> CustomerProperties = [Select Id,PrimaryOwnerId,FloorType,FoundationType,GarageType,
                LotArea,CeilingType,DwellingType,PurchasePrice,RoofType,BedroomCount,BuiltUpArea,EngineDisplacementVolume,FairMarketValue,FloorCount,IsBasementIncluded,
                IsChimneyIncluded,IsPassedSmogCheck,IsSwimmingPoolIncluded,PurchaseDate,YearBuilt
        from CustomerProperty where createdDate = Today];
        System.assert(CustomerProperties.size()>0, 'CustomerProperties Not created');
        System.Debug(LoggingLevel.DEBUG,'CustomerProperties:'+JSON.serialize(CustomerProperties));


        List<CoverageType> CoverageTypes = [Select Id,Category,CategoryGroup,CategoryGroupType,CategoryGroupTypeValue,DeductibleAmount,EffectiveDate,ExpirationDate,LimitAmount,LimitRange,Name,SourceSystemIdentifier
        from CoverageType where createdDate = Today];
        System.assert(CoverageTypes.size()>0, 'CoverageTypes Not created');
        System.Debug(LoggingLevel.DEBUG,'CoverageTypes:'+JSON.serialize(CoverageTypes));

        List<InsurancePolicy> InsurancePolicies = [Select Id,Name
        from InsurancePolicy where createdDate = Today];
        //System.assert(InsurancePolicies.size()>0, 'InsurancePolicies Not created');
        System.Debug(LoggingLevel.DEBUG,'InsurancePolicies:'+JSON.serialize(InsurancePolicies));

        Test.stopTest();
    }

    private static testMethod void test_Misc(){
        CognisureAPIRequestsTest.getCommonJSONAPIResponse();
        CognisureAPIRequestsTest.getCommonjsonAPIResp2();
        CognisureAPI.schedulebatchjobs();
    }

    @TestSetup
    private static void createTestData() {
        List<Sobject> cases = getCases();
        Insert cases;
        Case case0 = (case) cases[0];
        createEmailMessage(case0.Id);
        List<Sobject> submisisonList = getSubmissionList();
        insert submisisonList;
        CognisureAPIRequestsTest.runTestDataTest();
        MappingDefinitionCtrl.getStaticResourceData();

    }


    private static void createEmailMessage(String caseId) {
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        emailMessage.ParentId = caseId;
        emailMessage.fromAddress = 'billing@acme.com'; // from address
        emailMessage.fromName = 'Billing Department'; // from name
        emailMessage.toAddress = 'johnSmith@example.com';
        emailMessage.Subject = 'Hello';

        emailMessage.HtmlBody = 'Hello World';
        insert emailMessage;

        Attachment obj = new Attachment();
        obj.Body = Blob.valueOf('Test Blob');
        obj.ParentId = emailMessage.Id;
        obj.Name = 'Dummy.pdf';
        obj.ContentType = 'application/pdf';
        insert obj;

        System.debug([SELECT Id, HasAttachment FROM EmailMessage WHERE Id = :emailMessage.Id]);
    }

    private static List<Sobject> getCases() {
        String caseJSON = '[\n' +
                '  {\n' +
                '    "AccountId": null,\n' +
                '    "CaseNumber": "00001044",\n' +
                '    "ClosedDate": null,\n' +
                '    "Comments": null,\n' +
                '    "ContactEmail": null,\n' +
                '    "ContactFax": null,\n' +
                '    "ContactId": null,\n' +
                '    "ContactMobile": null,\n' +
                '    "ContactPhone": null,\n' +
                '    "Description": "Attaching both the documents\\n\\nThank you,\\nVenkata.",\n' +
                '    "FinServ__FinancialAccount__c": null,\n' +
                // '    "FinServ__Household__c": null,\n' +
                //'    "Id": "500Hp00001fQeMTIA0",\n' +
                '    "IsClosed": false,\n' +
                '    "IsDeleted": false,\n' +
                '    "IsEscalated": false,\n' +
                '    "MasterRecordId": null,\n' +
                '    "Origin": "Email",\n' +
                '    "ParentId": null,\n' +
                '    "Priority": "Medium",\n' +
                '    "Processed_By_Cognisure__c": false,\n' +
                '    "Reason": null,\n' +
                //'    "SourceId": "02sHp00001RwJDfIAN",\n' +
                '    "Status": "New",\n' +
                '    "Subject": "Documents from ABC TOP CO",\n' +
                '    "SuppliedCompany": null,\n' +
                '    "SuppliedEmail": "venkats@cognisure.ai",\n' +
                '    "SuppliedName": "VenkatS",\n' +
                '    "SuppliedPhone": null,\n' +
                '    "Type": null\n' +
                '  }\n' +
                ']';

        List<Sobject> caseList = (List<case>) JSON.deserialize(caseJSON, List<case>.class);
        return caseList;

    }

    private static String getMessageIdfromCSResponse() {
        String fileUploadResp = CognisureAPIRequestsTest.getFileUploadAPIResponse();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(fileUploadResp);
        String response_Id = (String) m.get('id');
        return response_Id;

    }

    private static Sobject getMetadata() {
        String metadataJSON = '[\n' +
                '  {\n' +
                '    "Base_URL__c": "https://pcqa.cognisure.ai:1099",\n' +
                '    "DeveloperName": "api_details",\n' +
                //'    "Id": "m0PHp0000004mUPMAY",\n' +
                '    "Label": "api-details",\n' +
                '    "Language": "en_US",\n' +
                '    "MasterLabel": "api-details",\n' +
                '    "NamespacePrefix": null,\n' +
                '    "Password__c": "Cognisure@40123",\n' +
                '    "QualifiedApiName": "api_details",\n' +
                '    "SystemModstamp": "2024-01-27T01:18:06.000+0000",\n' +
                '    "Token_Response_Key__c": "access_token",\n' +
                '    "Token_URL__c": "/token",\n' +
                '    "Upload_API_Endpoint__c": "/api/submission/upload",\n' +
                '    "Upload_API_Name_Parameter__c": "submissionName",\n' +
                '    "Upload_API_implementation__c": "CognisureAPI.EmailAttachmentForm64",\n' +
                '    "Username__c": "cssfapiuser@cognisure.ai"\n' +
                '  }\n' +
                ']';
        List<Sobject> metadataList = (List<Cognisureapi__mdt>) JSON.deserialize(metadataJSON, List<Cognisureapi__mdt>.class);
        return metadataList[0];
    }

    private static List<Sobject> getSubmissionList() {
        String SubmssionJSON = '[\n' +
                '  {\n' +
                '    "Case__c": null,\n' +
                '    "Common_JSON_Status__c": false,\n' +
                '    "Custom_JSON_Status__c": false,\n' +
                '    "Message_Id__c": null,\n' +
                '    "Name": "s-0001",\n' +
                '    "Submission_360_Status__c": false,\n' +
                '    "Submission_Id__c": null\n' +
                '  }\n' +
                ']';
        List<Sobject> SubmissionJSONList = (List<Submission__c>) JSON.deserialize(SubmssionJSON, List<Submission__c>.class);
        return SubmissionJSONList;
    }
    
    private static testmethod void testCustomSettingMapping(){
        Id submissionId = [Select id,name from Submission__c limit 1].Id;
        System.assert(submissionId!=null,'Submission Id is null');
        string jsonresp = CognisureAPIRequestsTest.getCommonJSONAPIResponse();
        ProcessSubmissionResponse_mdt.processJSONResponse('',submissionId);
        ProcessSubmissionResponse.processJSONResponse(jsonresp,submissionId);
        Account a = [Select id,name from account where CreatedDate=Today limit 1];
        System.assert(a!=null,'Account not created');
        List<Claim> claimsList = [Select id,name from Claim where createdDate = Today];
        System.assert(claimsList.size()>0,'Claims not created..');
    }

    private static void testInsertClaimRecords(){
        String claimJson = '[{"attributes":{"type":"Claim"},"Name":"Test0", "IsDrivable":"false", "Status":"Initial", "AccountId":"001DS00001M3osoYAB", "CaseId":"500DS00000FURuNYAX"}]';
        List<Claim> cliams = (List<Claim>)JSON.deserialize(claimJson,List<Claim>.class);
        Insert cliams;
    }

}

