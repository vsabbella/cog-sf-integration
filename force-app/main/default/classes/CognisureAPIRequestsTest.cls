/**
 * Created by venkatasabbella on 1/26/24.
 */

public with sharing class CognisureAPIRequestsTest {

    @TestVisible
    public static  void runTestDataTest(){
        CognisureAPIRequestsTest.getAuthTokenResponse();
        CognisureAPIRequestsTest.getFileUploadAPIResponse();
        CognisureAPIRequestsTest.getCommonJSONAPIResponse();
    }

    public static string getAuthTokenResponse(){
      String jsonmAuthTokenMinifiedResp = '{"access_token":"PvruGMAn1OzDtNVG570ZxoCReZYpQPQhXeciUkTu1MZNKBr9dRtQbRS1sjl5Sm9AB","token_type":"bearer","expires_in":1199,"userName":"cssfapiuser@cognisure.ai"}';
        return jsonmAuthTokenMinifiedResp;
    }
    public static string getFileUploadAPIResponse(){
      String statusAPIResponseMinfied = '{"id":"68ee0ae5-f680-41ae-b4ee-d96dbec1eb9a","returnCode":true,"message":"2 files out of 2 were successfully uploaded.","fileUploadResults":[{"fileOriginalName":"LossHistory.pdf","fileHash":null,"fileGUID":"285d57f3-1043-4080-b219-0ab9bb863a60","isBundle":false,"bundleID":null,"uploadedOn":"2024-01-27T05:51:49.947","fileReceivedChannelName":"API","user":"cssfapiuser@cognisure.ai","clientID":"1000","clientName":"CogniSure","extractionStatus":"InQueue","uploadedResult":"Success","uploadedResultCode":true,"uploadedResultMessage":"successfully uploaded"},{"fileOriginalName":"ABC TOP CO LLC10.pdf","fileHash":null,"fileGUID":"740310a7-51b8-41bd-b3a6-c83705d6ba70","isBundle":false,"bundleID":null,"uploadedOn":"2024-01-27T05:51:53.253","fileReceivedChannelName":"API","user":"cssfapiuser@cognisure.ai","clientID":"1000","clientName":"CogniSure","extractionStatus":"InQueue","uploadedResult":"Success","uploadedResultCode":true,"uploadedResultMessage":"successfully uploaded"}]}';
        return statusAPIResponseMinfied;
    }

   
    public static void test_ProcessJSONResponseFromStaticResource(){
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(
                                                                      new String[]{'Claim','Account','CustomerProperty'});
        System.debug(LoggingLevel.Debug, '@@@'+descResult[0].Fields.getMap().get('Name'));
        StaticResource SR = [Select id,name,body from StaticResource where Name = 'submissionrespunformatted'];
        String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        Delete [Select Id,name from Account where createdDate =Today];
        Delete [Select Id,name,ActualAmount,AssessmentDate,LossDate,Status from Claim ];
        Delete [Select Id,name,Address,format(createdDate), AnnualMileage, BuiltUpArea, CeilingType, City, ConstructionClass, Country  from CustomerProperty  ];
        Delete [Select Id,name from WorkerCompCoverageClass  ];
        Delete [Select Id,name from CoverageType  ];
        Delete [Select Id,name from Account where createdDate =Today];
        Delete [Select Id,name,ActualAmount,AssessmentDate,LossDate,Status from Claim ];
        ProcessSubmissionResponse.processJSONResponse(submissionResponseJson,'a00DS00000Byws2YAB');
    }

    public static void test_ProcessJSONResponseFromStaticResource2(){
      Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(
                                                                    new String[]{'Claim','Account','CustomerProperty'});
      System.debug(LoggingLevel.Debug, '@@@'+descResult[0].Fields.getMap().get('Name'));
      StaticResource SR = [Select id,name,body from StaticResource where Name = 'submissionrespunformatted2'];
      String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
      Delete [Select Id,name from Account where createdDate =Today];
      Delete [Select Id,name,ActualAmount,AssessmentDate,LossDate,Status from Claim ];
      Delete [Select Id,name,Address,format(createdDate), AnnualMileage, BuiltUpArea, CeilingType, City, ConstructionClass, Country  from CustomerProperty  ];
      Delete [Select Id,name from WorkerCompCoverageClass  ];
      Delete [Select Id,name from CoverageType  ];
      Delete [Select Id,name from Account where createdDate =Today];
      Delete [Select Id,name,ActualAmount,AssessmentDate,LossDate,Status from Claim ];
      ProcessSubmissionResponse.processJSONResponse(submissionResponseJson,'a00DS00000Byws2YAB');
  }
   
   
    public static string getCommonJSONAPIResponse(){
        String apiResp = '';
        return apiResp;
    }

    public static String getCommonJsonAPIResponse_ClaimNameEmpty(){
      String apiResp = '';

      return apiResp;
    }
    
    public static string getCommonjsonAPIResp2(){
      List<StaticResource> sr = [Select id,name,body from StaticResource where Name = 'submissionrespunformatted'];
      String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr[0].body)).toString();



      return submissionResponseJson;
    }


}