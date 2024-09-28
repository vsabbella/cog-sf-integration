

**# Technical Design:

Overview of the integration solution: 

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXcIxj2h548Qx2iBSGULV2wAavYHlwB1HQD4FxoOY_vmUA5h0EIgWQkXtGTzT2UzFJls-_VlkuRJdtR9AZzoWlft0-R9wLl9WDBDHgXT8nndt7i_efS97TN8d1Hhv8Mxg5kDrqSAxHBjQ229xNZfZUKkAOG0?key=zDhOLRE9V3jv2FH3UC65Dw)

  

### C1: 

An email to case process has been configured to test the case creation, email and attachment processing in salesforce. Customers can have varying configuration and setup in the way  cases and email attachments are handled in their organization depending on their business process. The package is configured to query from email attachments under a case.  This needs to be updated accordingly as per respective customer business process configuration in salesforce. 

### B1: 

A batch job uploads the attachments under case to Cognisure server. Salesforce limits the size of attachments and number of attachments  that can uploaded to Cognisure. During testing I  have identified the limit to be 6 MB per upload. We need to find ways around this limitation to process larger files attached to case.

### J1: 

A batch job gets JSON response from commonJSON API from Cognisure to create FSC data in Salesforce. 

This FSC data at this time is limited to the following objects.

List of Objects: 

Account,Claim,CustomerProperty,WorkerCompCoverageClass,CoverageType,InsurancePolicy

  
  

The response is mapped from JSON to FSC data using Custom metadata Common_JSON_Mapping_Setting. Refer to static resources in this document. For the initial design of this solution, an outer level key in data is mapped to one FSC object. 

Example : 

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXfaDQjxOv4jsLNs9ddFkHeuPFDMukVKeylpkycVrYDIPZ28mLb39G2luIKyqM02ehGRbCWCc8oWybeeniv3oNF9E31W0lvS45w2EyqRSqv3ZLCI34pwFVcmV6StnbzHpdJ1O3tZt3pUrvf19gyQSwIHx4mT?key=zDhOLRE9V3jv2FH3UC65Dw)

Response Object Key : - Outer level Key within the data Key of the JSON response. For example Claim_info 

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXe20DuHvVMIqZUkA4Mlnocdx7ybZNFWop959ZJUwWiyQJV1eFfQtF8WShTbzYukIULpf0ByUVUrfwj7kJda59NDKERODd1O4nKGT8TMratkbUqXeUb15Ud1l34J-Fa9mDPQvaTaXrhiRDnJIFvY8cST0-qp?key=zDhOLRE9V3jv2FH3UC65Dw)

Active: To consider or ignore the mapping when checked or disabled respectively.

Response Field Key :  Inner key within the outer object key with in data key of the response.For ex Insured_Nm

Sobject : Mapped to a Claim object within salesforce. Example Claim.

Field: Mapped to Field API name within salesforce. - Example Claim Name.

We are not using Default Value as of now on this custom metadata. 

Sequence: Sequence in which the objects get processed. 

All the Account objects mapping are with sequence 1.1

All the Claim objects mapping are with sequence 2.1

All the Coverage Type objects mapping are with sequence 3.1 and so on. 

Use a different sequence

Table 1.1

|   |   |   |   |   |
|---|---|---|---|---|
|Salesforce Object|Response Object|Response Field|Salesforce Field|Seq|
|Account|Account_Level_Info|Any|Any|1.1|
|Claim|Claim_Info|Any|Any|2.1|
|CustomerProperty|Property_Policy_Info_Premises_Information|Any|Any|3.1|
|CoverageType|Property_Policy_Info_Premises_Information|Any|Any|4.1|
|WorkerCompCoverageClass|WC_Policy_Info_State_Rating_Worksheet|Any|Any|5.1|

  

For same combination of salesforce object and Response object, use same order/seq.

For any other different combination, use a different order / sequence. Example 

Table 1.2

|   |   |   |   |   |
|---|---|---|---|---|
|Salesforce Object|Response Object|Response Field|Salesforce Field|Seq|
|Claim|Property_Policy_Info_Premises_Information|Any|Any|6.1|

Table 1.2 has an example mapping not currently in the system. But observe the sequence number for a new combination of Salesforce Object and Response Object. 

Table 1.3

  

|   |   |   |   |   |
|---|---|---|---|---|
|Salesforce Object|Response Object|Response Field|Salesforce Field|Seq|
|Claim|Claim_Info|Any|Any|2.1|

If you want to add a new mapping, check the combination of Salesforce Object and Response Object. If it exists in the mapping in the system, re-use the same sequence number. Refer table .1.3 for example. 

  
  

Follow the same convention to add additional mappings as this has performance impact. 

Total mapping being supported is upto 130 only. We need to refactor our code to add mappings beyond this. 

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdyh-UROGn3WWETvHBT2x3JtcQhZceduCol0tMWbfa7Yd4rlgy4Qp7jm1g397knfa8jsXOkQNX--tLt45vzgEpL_YfjOrAVkXjqktTiGgyeBrFY6356LBexrxc-Xcdi30_wsQhP5xVObqqN5Isdj5dmjelZ?key=zDhOLRE9V3jv2FH3UC65Dw)

  
  

### Custom response interceptors : 

At the customer org level, developers can define plugins to overwrite the default mapping from static resource to adjust the data of FSC objects according to the customer business process. Developers can define these plugins implementing  the interface from the package. 

  

The name of the class implementing the interface should be updated on the Custom metadata for package to invoke the interceptor plugin. 

The plugins are provided as a way to update custom fields on FSC data to work around validation rules and required fields configurations that vary across customer salesforce orgs. 

  
  

### Flow of Data:

CSFileUploadAPIConsumerBatch , cssubmissionbatch batch jobs are scheduled to run every 1 min. 

CSFileUploadAPIConsumerBatch uploads email messages from new cases to Cognisure server and creates submission records storing the message Id from Cognisure which is subsequently used for checking status or getting JSON response from Cognisure. 

Once Cognisure complets processing files, Cognisure will call a salesorce API to update Common JSON checkbox on submission object record. The batch job cssubmissionbatch will call Common JSON Cognisure API to get JSOn response and insert FSC records based on the definition in the static resources. 

### Static Resources:

  

|   |   |   |
|---|---|---|
|Component Name|Type|Description|
|cognisure_sffield_defaults|Static Resource|JSON definition specifying FSC object defaults for missing data from response|
|cognisurefieldmap|Static Resource|JSON definition for mapping Cognisure response elements to FSC objects fields. Not using anymore, moved to Custom metadata. Refer to section J1|
|cognisure_Sobject_External_Ids|Static Resource|JSON definition for sobject external Ids|
|cognisure_Sobject_Mapping|Static Resource|JSON definition for mapping Cognsure response to FSC objects. Not using anymore. Refer to section J1.|
|submissionrespunformatted|Static Resource|Sample JSON response from Cognsiure from common json API - Not using anymore.|

  

### Custom Objects: 

|   |   |   |
|---|---|---|
|Component Name|Type|Description|
|Submission__c|Custom Object|Submission for tracking upload and response processing|

  
  

### Custom metadata:

  

|   |   |   |
|---|---|---|
|Component Name|Type|Description|
|Cognisureapi__mdt|Custom Meta Data Definition|Metadata used by App for consuming Cognsure APIs|

  

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdeLnVRXkDZaLEN41eSHuqIR8ZO5PL9HghY93gJV2B7HS-Ww43dKoGCpxNoBur7UKNqbHSiOHWmqtW8P-Jnqp4MaqV1ZlXtGIdhpeMMY_MI8X7CB7CiKyTBUZ3JgRXhdELNgcssyIncguDHB9BUs7FZ159a?key=zDhOLRE9V3jv2FH3UC65Dw)

  

### Named Credentials:

  

|   |   |   |
|---|---|---|
|Component Name|Type|Description|
|cognisureai|Named Credentials|Credential for Cognisure Sever|

  
  
  

### Apex Classes:

  
  

|   |   |   |
|---|---|---|
|Component Name|Type|Description|
|CSFileUploadAPIConsumerBatch|Apex Class|Batch apex to upload files, uses vNHttpFormBuilder|
|CognisureAPI|Apex Class|Global class providing interfaces and other utility methods|
|CognisureAPIConsumerCtrl|Apex Class|Controller Class Containing HTTP methods for calling APIs|
|CognisureAPIConsumerCtrlTest|Apex Class|Test class for CognisureAPIConsumerCtrl|
|CognisureAPIConsumerScheduler|Apex Class|Used for scheduling Batch Jobs|
|CognisureAPIRequestsTest|Apex Class|Contains method that provide JSON data to mimic response from Cognisure|
|CognisureAuthTokenMockImpl|Apex Class|Mock Implementation for test class for Auth Token API|
|CognisureCommonJsonMockImpl|Apex Class|Mock Implementation for test class for Common JSON API|
|CognisureFileUploadMockImpl|Apex Class|Mock Implementation for test class for Upload API|
|CognisureStatusMockImpl|Apex Class|Mock Implementation for test class for Status API|
|ProcessSubmissionResponse|Apex Class|Invoked from Batch, Handler class that processes common JSON response from Cognisure|
|UploadAPIResponseProcessor|Apex Class|Process JSON response from Upload API|
|cssubmissionbatch|Apex Class|Batch apex to process response from Cognisure|
|vNHttpFormBuilder|Apex Class|Utility Class that Call Multipart API to upload files to Cognisure Server|

  

###  Custom Fields : 

  

|   |   |
|---|---|
|Component Name|Type|
|Cognisureapi__mdt.Base_URL__c|Custom Field|
|Cognisureapi__mdt.Common_JSON_URL__c|Custom Field|
|Cognisureapi__mdt.Email_Message_Query_Plugin__c|Custom Field|
|Cognisureapi__mdt.NamedCredentail__c|Custom Field|
|Cognisureapi__mdt.Password__c|Custom Field|
|Cognisureapi__mdt.Submission_Query_Plugin__c|Custom Field|
|Cognisureapi__mdt.Token_Response_Key__c|Custom Field|
|Cognisureapi__mdt.Token_URL__c|Custom Field|
|Cognisureapi__mdt.Upload_API_Endpoint__c|Custom Field|
|Cognisureapi__mdt.Upload_API_Plugin__c|Custom Field|
|Cognisureapi__mdt.Field_Default_Definition__c|Custom Field|
|Cognisureapi__mdt.Field_External_Id_Definition__c|Custom Field|
|Cognisureapi__mdt.Field_Mapping_Definition__c|Custom Field|
|Cognisureapi__mdt.FSC_Object_Response_Map_Definiton__c|Custom Field|
|Cognisureapi__mdt.Submission_Id__c|Custom Field|
|Submission__c.Case__c|Custom Field|
|Submission__c.Common_JSON_Status__c|Custom Field|
|Submission__c.Custom_JSON_Status__c|Custom Field|
|Submission__c.Message_Id__c|Custom Field|
|Submission__c.Submission_360_Status__c|Custom Field|
|Submission__c.Submission_Id__c|Custom Field|
|Submission__c.processed_commonjson__c|Custom Field|
|Claim.Cause_of_Loss__c|Custom Field|
|CustomerProperty.Premises_Number__c|Custom Field|
|CustomerProperty.Building_Number__c|Custom Field|
|CustomerProperty.Occupancy__c|Custom Field|
|CustomerProperty.Protection_Class__c|Custom Field|
|CustomerProperty.Wiring_Year__c|Custom Field|
|CustomerProperty.Plumbing_Year__c|Custom Field|
|CustomerProperty.Roofing_Year__c|Custom Field|
|CustomerProperty.Heating_Year__c|Custom Field|
|WorkerCompCoverageClass.Rating_State__c|Custom Field|
|WorkerCompCoverageClass.Rateclass_Rate__c|Custom Field|

  
  

### Others : 

  

|   |   |   |
|---|---|---|
|Component Name|Type|Description|
|Cognisureapi.api_details|CustomMetadata|Custom Metadata Detail|
|cos|RemoteSiteSetting|Remote site setting for Cognisure API|
|cognisureai|NamedCredential|Username and Password for Cognsire API|
|Cognisuire_AI|PermissionSet|Permission Set for fields and customobjects|

  

### APIs:

  

Server URL : [https://api.cognisure.ai](https://api.cognisure.ai)

  

Token API URL : /token

Body parameters : granttype, username , password

Upload API URL: 

/api/submission/upload?id=&submissionName=Test Demo&X-Unique-Id=Test0123

Stataus  API URL:

/api/submission/status/?id={{subGUID}}

Common JSON API URL: 

/api/submission/commonjson/?id={{subGUID}}

  

Salesforce Login SOAP API: 

URL : [https://login.salesforce.com/services/Soap/u/50.0](https://login.salesforce.com/services/Soap/u/50.0)

Replace login with test for sandboxes

Body : Refer to Postman Extract

  

Salesforce API for uploading excel file to salesforce: 

Base URL : Get it from Login SOAP API

URL : /services/data/v53.0/sobjects/Attachment/

  

Salesforce API for notification for  completion of common json: 

Base URL : Get it from Login SOAP API

/services/data/v53.0/composite

Body: 

Refer to postman Extract

  

Static Resources : Not using below static resources anymore

1. Cognisure_sffield_defaults
    

Use this static resource to define default values for the fields that are needed to be populated. 

2. Cognisurefieldmap
    

1. Use this static resource to define mapping from Cognisure response to Salesforce force fields
    

  

Batch Jobs : 

1. CSFileUploadAPIConsumerBatch - Upload files from case to Cognisure API
    
2. Cssubmissionbatch - Process JSON response from the uploaded files. 
    

  

Test Class Coverage : 

  

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdz1OHVKdBpSYGuEmp_Vv2pFo2UEzdh0A3hY8tRwoMywTSSW36HC7tXbqxu_Ul71NyRf565iq1SYY8f7aDohKP-KnpbDWT_wNeHBZK5BiI27tMuFx0lClmMNVsWiAKSjgZTQoytm5R9mnqshH77K-oV1HAC?key=zDhOLRE9V3jv2FH3UC65Dw)

  

  

  

Prerequisites : 

  

  

  

1. Permissions that needs to be enabled in the target org : 
    

1. Setup →Insurance settings → Enable Access Main List of Coverage Types
    
2. [https://help.salesforce.com/s/articleView?id=sf.fsc_insurance_admin_unlock_additional_features.htm&type=5](https://help.salesforce.com/s/articleView?id=sf.fsc_insurance_admin_unlock_additional_features.htm&type=5)
    
3. ### Use Many-to-Many Relationships
    
4. ### Let Multiple Producers Work on the Same Policy
    

  

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXfrzcGSpqQd9shqXul-akTj843AM6S3F6ojTZpkpPCehb4Wg6HqHBUJ1MERFF2hpv9Gee1xi0lqD_AP1ewyo8qdMp5YtxPPm-emw2ZajGXNSOsUPI3aWgh9SL9jgzxcY9hdIDW-xDY5bjDecO1oho3LSsw?key=zDhOLRE9V3jv2FH3UC65Dw)

  

2. Assign the permission set Cognisuire-AI to the admin user running the batch job. This provides access to named credentials that contain username and password. 
    
3. Enter the username and password in the external credential details  for Named credential cognisureai
    

  

Email-To-Case Configuration: 

Setup→ Email-To-case 

  

  

### Package Installation and Post Installation settings: 

Link to the package : 

https://login.salesforce.com/packaging/installPackage.apexp?p0=04tHr0000013PwoIAE

4. FSC Licenses enabled in the org. - May not be required as dependency is removed. Although needs to be double checked when installing in customer org. 
    
5. FSC Managed package installed. - dependency removed, Manual configuration in org
    

  

Schedule the batch jobs : 

Cron Expression : 

0 48 * * * ?  - To schedule for every 10 mins. 

  

Update allowed namespaces in the named credential cognisure ai - get the namespace from the custom metadata.

  

Updating the cognisure server instance to a different once : 

api.cognisure.ai

  

### Out of scope for initial implementation of the package: 

1. FSC Objects outside the scope of the listed object are not supported for the initial implementation of the package. 
    
2. Default plugins code are provided for reference, but the changes or new plugins should be developed based on requirements for resective customer. 
    
3. Governor limits imposed by salesforce can limit the functionality of the package in the customer org depending on the customer and licenses/editions they have. Debugging governors at the customer org level is not in the scope of initial package implementation.
    
4. Refer to the overview of integration for features developed as part of initial implementation of the package. Initial implementation is limited to boxes/elements defined in the diagram. 
    
5. Using external ids to update the same data is outside the scope of initial implementation as JSON data does not provide external Ids at this moment. Refer to sample responses tested as part of this solution. 
    
6. Refer to the postman extract of APIs and response structure to which Initial solution of the package is developed. Changes to APIs and response structure can affect the solution of the packages delivered. 
    
7. CI/CD is outside scope of initial implementation of this package.
    
8. Scope of this assignment is limited to features developed and tested for this solution. Features not developed and not tested are not part of the scope of this solution. 
    

  

Installation and Post Installation configuration How tos:**