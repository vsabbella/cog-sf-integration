public with sharing class ProcessSubmissionResponse {
    Class CustomResponseException Extends Exception{}
    public ProcessSubmissionResponse() {

    }

    private static sobject cognisureapimetadata {
        get {
            if (cognisureapimetadata == null) {
                cognisureapimetadata = (Sobject) Cognisureapi__mdt.getInstance('api_details');
                if (test.isRunningTest()) {
                    cognisureapimetadata = getMetadata();
                }
            }
            return cognisureapimetadata;
        }
        private set;
    }

    private Static StaticResource fsc_sobject_field_defaults{
        get{
            if(fsc_sobject_field_defaults ==null){
                List<StaticResource> srList = [Select Id,name,body from StaticResource where Name = : (String) cognisureapimetadata.get('Field_Default_Definition__c')];
                if(srList.size()>0){
                    fsc_sobject_field_defaults = srList[0];
                }
                if(test.isRunningTest()){
                    fsc_sobject_field_defaults = MappingDefinitionCtrl.get_cognisure_sffield_defaults_sr();
                }
            }
            return fsc_sobject_field_defaults;
        }
        private set;
    } 

    private Static StaticResource fsc_Sobject_Mapping{
        get{

            if(fsc_Sobject_Mapping==null){
                List<StaticResource> srList = [Select Id,name,body from StaticResource where Name = : (String) cognisureapimetadata.get('FSC_Object_Response_Map_Definiton__c')];
                if(srList.size()>0){
                    fsc_Sobject_Mapping = srList[0];
                }
                if(test.isRunningTest()){
                    fsc_Sobject_Mapping = MappingDefinitionCtrl.get_cognisure_Sobject_Mapping_sr();
                }
            }

            return fsc_Sobject_Mapping;
        }
        private set;
    } 

    private Static StaticResource fsc_Sobject_ExternalId_Info{  
        get{
            if(fsc_Sobject_ExternalId_Info==null){
                List<StaticResource> srList = [Select Id,name,body from StaticResource where Name = : (String) cognisureapimetadata.get('Field_External_Id_Definition__c')];
                if(srList.size()>0){
                    fsc_Sobject_ExternalId_Info = srList[0];
                }
                if(test.isRunningTest()){
                    fsc_Sobject_ExternalId_Info = MappingDefinitionCtrl.get_cognisure_Sobject_External_Ids_sr();
                }
            }
            return fsc_Sobject_ExternalId_Info;
        }
        private set;
    } 

    private Static StaticResource cognisure_field_map_sr{
        get{

            if(cognisure_field_map_sr==null){
                List<StaticResource> srList = [Select Id,name,body from StaticResource where Name = : (String) cognisureapimetadata.get('Field_Mapping_Definition__c')];
                if(srList.size()>0){
                    cognisure_field_map_sr = srList[0];
                }
                if(test.isRunningTest()){
                    cognisure_field_map_sr = MappingDefinitionCtrl.get_cognisurefieldmap_sr();
                }
            }
            return cognisure_field_map_sr;
        }
        private set;
    } 
   
    public static void processJSONResponse(String JSONRepsonse, Id submissionSobjId){


        //StaticResource SR = [Select id,name,body from StaticResource where Name = 'submissionrespunformatted'];
        //String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        String submissionResponseJson =  JSONRepsonse;
        //System.debug(LoggingLevel.debug, '-->'+submissionResponseJson);
        Map<String,Id> parentSobjectIds = new Map<String,Id>(); 
       
        Map<String,String> SobjectMapping = getSobjectMapping();
        //comes from static resouce mapping: CustomeObject => Response Element
        List<String> SobjectTypeList = new List<String>(SobjectMapping.keySet());

        if(SobjectTypeList.size()>0){
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(submissionResponseJson);
        String dataJson = (String)m.get('data');
        
        if(String.isBlank(dataJson)){
            Throw New CustomResponseException('No Data In Response');
        }

        String sobjectsToCreate = getSobjectsForDML();
        Set<String> sobjectsToCreateList = new Set<String>(sobjectsToCreate.split(','));

        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(dataJson);
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(
            SobjectTypeList);
        Map<String,Schema.DescribeSObjectResult> descResMap = new Map<String,Schema.DescribeSObjectResult>(); 
        for(Schema.DescribeSObjectResult descResult_iter:descResult){
            descResMap.put(descResult_iter.getName(),descResult_iter);
        } 
        System.debug(LoggingLevel.debug,'descresMap keyset:'+descResMap.keySet());

        Submission__c SubsmsisonSobjRecord = [Select Id,name,case__c from Submission__c where Id =:submissionSobjId];
        Id caseId = SubsmsisonSobjRecord?.case__c;
        if(!String.isBlank(caseId)){
            parentSobjectIds.put('caseid',caseId);
        }

        for(String SobjectTypeStr:SobjectMapping.keySet()){
            if(sobjectsToCreateList.contains(SobjectTypeStr)){
                String ResponseElementStr = SobjectMapping.get(SobjectTypeStr);
                if(!String.isBlank(ResponseElementStr)){
                    System.debug(LoggingLevel.Debug, 'sobjectType: '+sobjectTypeStr+': Response Element Str:'+ResponseElementStr);
                    if(m1.containsKey(ResponseElementStr)){
                        List<Object> ResponseElement = (List<Object>)m1.get(ResponseElementStr); //object
                        if(ResponseElement!=null && ResponseElement.size()>0){
                            List<Sobject> sobjList0 = processSobjectInfo(ResponseElement, sobjectTypeStr,descResMap.get(sobjectTypeStr));
                            System.debug(LoggingLevel.Debug,'Count of Object'+sobjList0.size());
                            //Specific to Account sobject
                            if(!parentSobjectIds.containsKey('accountid')){
                                if(sobjectTypeStr=='Account'){
                                    String AccountName = (String)sobjList0[0].get('Name');
                                    List<Account> accountList = [Select Id,name from Account where name =:AccountName limit 1];
                                // Todo Use External Id - External Id needs to come from cognisure response - Only getting name at this time
                                if(accountList.size()>0){
                                    parentSobjectIds.put('accountid',accountList[0].Id);
                                }
                                else{
                                    if(sobjList0.size()>0){
                                        List<Sobject> sobjList1 = new List<Sobject>{sobjList0[0]};
                                        List<Id> Ids = upsertOrInsertSFRecords(sobjList1,sobjectTypeStr,descResMap.get(sobjectTypeStr));
                                        System.debug(LoggingLevel.Debug, 'Count of Ids Inserted/Updated'+ Ids.size()+': End');
                                        if(sobjectTypeStr=='Account'){
                                            parentSobjectIds.put('accountid',Ids[0]);
                                        }
                                    }
                                    
                                 }
                                }
                            }
                            else{
                                 //for rest of sobjects like claims, customerproperties, etch
                                 if(SobjectTypeStr!='Account'){
                                    if(sobjList0.size()>0){
                                        assignSObjectSpecificFields( SobjectTypeStr, sobjList0, parentSobjectIds);
                                        upsertOrInsertSFRecords(sobjList0,sobjectTypeStr,descResMap.get(sobjectTypeStr));
                                    }
                                 }
                                 
                            }
                        }
                        else {
                         //Todo: If the response element is not found in the response. Throw an error??- What if this response element is optional?
                        }
                        
                    }
                    else{
                        //Todo: If the response element is not found in the response. Throw an error??- What if this response element is optional?
                    }
                    
                }
            }
            
        }

     }
    }


    //ProcessSubmissionResponse.processJSONResponse_0

    /*public static void processJSONResponse_0(String JsonResponse){


        String submissionResponseJson = JsonResponse;

        //Map<String,Object> myMap =  Map<String,Object> JSON.serializeUnTyped();
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(submissionResponseJson);
        String dataJson = (String)m.get('data');
        System.debug(LoggingLevel.debug, '-->2.'+dataJson);
        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(dataJson);
        List<Object> Account_Level_Info = (List<Object>)m1.get('Account_Level_Info'); //object
        List<Object> Claim_Info = (List<Object>)m1.get('Claim_Info');//array
        //List<Sobject> claims = processClaimsInfo(Claim_Info, 'Claim');
        List<Object> Property_Policy_Info_Premises_Information = (List<Object>)m1.get('Property_Policy_Info_Premises_Information');//array
        List<Object> Property_Policy_Info_Blanket_Summary = (List<Object>)m1.get('Property_Policy_Info_Blanket_Summary');//array
        Object metaData = (Object)m1.get('metaData');// object
    }*/

    private static String getSobjectsForDML(){
         sobject  cognisureapimetadata = (Sobject) Cognisureapi__mdt.getInstance('api_details');
         return (String)cognisureapimetadata.get('Objects_To_Create__c');
    }

    public static void assignSObjectSpecificFields(String SobjectTypeStr,List<Sobject> sobjectList, Map<String,String> parentSobjectIds){
        if(sobjectTypeStr == 'Claim'){
            for(Sobject sobj0:sobjectList){
                if(parentSobjectIds.containsKey('accountid')){
                    sobj0.put('AccountId', parentSobjectIds.get('accountid'));
                }
                if(parentSobjectIds.containsKey('caseid')){
                    sobj0.put('CaseId', parentSobjectIds.get('caseid'));
                }
            }
            
         }
         else if( sobjectTypeStr == 'CustomerProperty'){
            for(Sobject sobj0: sobjectList){
                sobj0.put('PrimaryOwnerId', parentSobjectIds.get('accountid'));
            }

         }
    }

    public static List<Id> upsertOrInsertSFRecords(List<Sobject> sobjList, String sobjectTypeStr, Schema.DescribeSObjectResult descRes){
        List<Id> Ids;
        Map<String,String> sobjectExternalIdInfo = getSobjectExternalIdInfo();
        if(sobjectExternalIdInfo.containsKey(sobjectTypeStr) && !String.isBlank(sobjectExternalIdInfo.get(sobjectTypeStr))){
            //System.debug(LoggingLevel.Debug,'@@@'+descResMap.get(sobjectTypeStr).Fields.getMap().get('Cognisure_External_Id__c'));
            String externalIdToken = sobjectExternalIdInfo.get(sobjectTypeStr);
        Schema.SObjectField fieldToken2 = descRes.Fields.getMap().get(externalIdToken);
            Database.UpsertResult[] results ;
                if(fieldToken2!=null){
                    //results = database.Upsert(sobjList1,fieldToken); 
                    //System.debug(LoggingLevel.Debug, '-->claims'+results.size());
                    //System.debug(LoggingLevel.Debug, '-->claims'+results);
                    Ids=upsertRecords(sobjList,fieldToken2);
                }
            //Upsert claims Name;
         }
         else {
            Ids = insertRecords(sobjList);
         }

         return Ids;
    }

    public static Map<String,String> getSobjectExternalIdInfo(){
        StaticResource SR =  fsc_Sobject_ExternalId_Info;
        String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        Map<String, String> m = (Map<String, String>)JSON.deserialize(submissionResponseJson,Map<String, String>.class);
        return m;

    }

    public static Map<String,String> getSobjectMapping(){
        StaticResource SR =  fsc_Sobject_Mapping;
        String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        Map<String, String> m = (Map<String, String>)JSON.deserialize(submissionResponseJson,Map<String, String>.class);
        return m;

    }

    

    private static List<Id> upsertRecords(List<Sobject> sobjectList, Schema.SObjectField fieldToken){
        List<Id> Ids = new List<Id>();
        Database.UpsertResult[] results00 ;
        results00 = database.Upsert(sobjectList,fieldToken,false);
        for(Database.UpsertResult Res : results00){
            if(Res.isSuccess()){
               Ids.add(Res.getId());
            }
            else {
                //Todo Thow Error Message here or log it into another object
            }
        }
        return Ids;
    }

    private static List<Id> insertRecords(List<Sobject> sobjectList){
        List<Id> Ids = new List<Id>();
        Database.SaveResult[] results0 ;
        results0 = database.Insert(sobjectList,false); 
        for(Database.SaveResult Res : results0){
            if(Res.isSuccess()){
               Ids.add(Res.getId());
            }
            else {
                //Todo Thow Error Message here or log it into another object
            }
        }
        return Ids;
    }
    

	private static List<Sobject> processSobjectInfo(List<Object> respObjList, String sobjectType, DescribeSObjectResult descSobjRes){
        

        //DescribeSObjectResult descSobjRes = descResMap.get(sobjectType);
       //System.debug(LoggingLevel.Debug, 'respObjList:'+JSON.serialize(respObjList));
       System.debug(LoggingLevel.Debug, 'respObjList size'+respObjList.size());
       List<Sobject> sobjList = new List<Sobject>();
       for(Object obj:respObjList){
           System.debug(LoggingLevel.debug, 'obj: '+JSON.serialize(obj));

           Sobject sobj_sobjType = descSobjRes.getSObjectType().newSObject();
           populateSobjectWithFieldValues(sobj_sobjType,descSobjRes,obj,sobjectType);
           populateSobjectDefaults(sobjectType,sobj_sobjType,descSobjRes);
           sobjList.add(sobj_sobjType);
       }
        System.debug(LoggingLevel.ERROR, 'processsubmission respopnse :Processing Sobject Type'+sObjectType);
        String commonJSONResponseHandlerInstance = cognisureapimetadata.get('Record_Field_Setter_Plugin__c')!=null?(String) cognisureapimetadata.get('Record_Field_Setter_Plugin__c'):'CognisureAPI.sobjectrecordsinterceptor';
        CognisureAPI.CommonJSONResponseHandler cjrh  = (CognisureAPI.CommonJSONResponseHandler) Type.forName(commonJSONResponseHandlerInstance).newInstance();
        cjrh.overwriteSObjectFieldValues(sobjList[0].getSObjectType() ,sobjList);
       return sobjList;
        
	} 

    public static void populateSobjectDefaults(String Sobjectname , Sobject sobj,Schema.DescribeSObjectResult descSobjRes){
       StaticResource Sr = fsc_sobject_field_defaults;
       String DefaultfieldMapStr =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
       //System.debug(LoggingLevel.debug, '-->'+JSON.serialize(DefaultfieldMapStr));
       
       Map<String,Object> DefaultfieldMapByObject = (Map<String, Object>)JSON.deserializeUntyped(DefaultfieldMapStr);
       Map<String,Object> DefaultsMap_Sobject = (Map<String,Object>)DefaultfieldMapByObject.get(Sobjectname);
       

       if(DefaultsMap_Sobject!=null){
        for(String Str : DefaultsMap_Sobject.keySet()){
            if(!Sobj.isSet(Str)    ) {
              Schema.SobjectField fieldToken = descSobjRes.fields.getMap().get(Str);
              Schema.DescribeFieldResult dfr = fieldToken.getDescribe();
              Object o = (Object)DefaultsMap_Sobject.get(Str);
              System.debug(LoggingLevel.Debug, 'fieldName: '+dfr.getName()+': Type: '+dfr.getSoapType());
              o=convertFieldValueToObject(dfr.getName(), o,String.valueOf(dfr.getSoapType()));
              System.debug(LoggingLevel.Debug, ''+o);
              sobj.put(Str,o);
            }
               
         }
       }
       

    }
    
    public static void populateSobjectWithFieldValues(Sobject sobj,Schema.DescribeSObjectResult descSobjRes, Object resp_obj,String SobjType){
       System.debug(LoggingLevel.Debug, 'SobjectType:'+sobj.getSObjectType()); 
       StaticResource Sr = cognisure_field_map_sr;
       String fieldMapDefinition =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
       System.debug(LoggingLevel.debug, 'resp_obj:'+JSON.serialize(resp_obj));
       
       Map<String,Object> res_obj_field_values = (Map<String,Object>)resp_obj;
       System.debug(LoggingLevel.Debug,'response obj serialized:'+JSON.serialize(res_obj_field_values));
       //Map<String,Object> myMap =  Map<String,Object> JSON.serializeUnTyped();
       Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(fieldMapDefinition);
       Map<String,Object> mapDefinition_Sobj = (Map<String,Object>)m.get(SobjType);
       
       if(mapDefinition_Sobj!=null){
        for(String sobjFieldStr: mapDefinition_Sobj.keySet()){
            System.debug(LoggingLevel.Debug,'Definiton Key:'+sobjFieldStr);
            if(descSobjRes.fields.getMap().containsKey(sobjFieldStr)){
                Schema.SobjectField fieldToken = descSobjRes.fields.getMap().get(sobjFieldStr);
                Schema.DescribeFieldResult dfr = fieldToken.getDescribe();
                String definitionMap_SobjFieldValue = (String)mapDefinition_Sobj.get(sobjFieldStr);
                Object response_obj_fieldValue = res_obj_field_values.get(definitionMap_SobjFieldValue);
    
                System.debug(LoggingLevel.Debug,'Definiton Key:'+sobjFieldStr);
                System.debug(LoggingLevel.Debug,'Definition value:'+definitionMap_SobjFieldValue);
                System.debug(LoggingLevel.Debug,'Definition Response:'+String.valueOf(response_obj_fieldValue));
    
                
                System.debug(LoggingLevel.Debug,'sobj field value'+Json.serialize(response_obj_fieldValue));
                if(dfr.isUpdateable()){
                    if(response_obj_fieldValue!=null){
                        Object value = convertFieldValueToObject(dfr.getName(), response_obj_fieldValue,String.valueOf(dfr.getSoapType()));
                        sobj.put(sobjFieldStr,value);
                    }
                }
            }
           }
       }
       
 
    }

    public static Object convertFieldValueToObject(String field, Object response_claimfieldValue, String reqdatatype){

       //Map<String,Object> o = (Map<String,Object>) claimObj;
       Object value = response_claimfieldValue;
       //String str =  getInputValueAsString( value);

       if(reqdatatype=='STRING'){
          if(value instanceof String){
             return value;
          }
       }
       if(reqdatatype=='BOOLEAN'){
        if(value instanceof String){
            String str;
            Boolean b ;
            if(value!=null){
                 str = String.valueOf(value);
                 b = String.isBlank(str)?Boolean.valueOf(str):false;
            }
               
               return (Object)b;
         }
         else if(value instanceof Boolean){
            return value;
         }
         else return false;
       }
       if(reqdatatype=='DATETIME'){
        if(value instanceof String){
            if(value!=null){
                DateTime DT;
                String dateStr = String.valueOf(value);
                if(dateStr.contains('T')){
                    String val = dateStr; 
                    DateTime date1 = (DateTime)Json.deserialize('"'+val+'"', DateTime.class);
                    DT = date1;
                }
                else{
                    Date assessmentDate;
                    
                    if(!String.isBlank(dateStr)){
                         assessmentDate = Date.parse(dateStr);//Valuation_Date
                         DT = DateTime.newInstance(assessmentDate.year(), assessmentDate.month(), assessmentDate.day());
                    }
                }
                
                
                return (Object)DT;
            }
              
         } 
         else return null;
       }
       if(reqdatatype=='DATE'){
        if(value instanceof String){
            if(value!=null){
                String dateStr = String.valueOf(value);
                Date d;
                d = !String.isBlank(dateStr)?Date.parse(dateStr):null;//Valuation_Date
                return (Object)d;
            }
              
         }
          
         else return null;
       }
       if(reqdatatype=='DOUBLE'){// Number, Currency
        if(value instanceof String){
            if(value!=null){
                String valueStr = String.valueOf(value);
                valueStr = valueStr.replaceAll(',', '');
                valueStr = valueStr.replaceAll('\\$', '');
                Double d;
                d = !String.isBlank(valueStr)?Double.valueOf(valueStr):null;
                return (Object)d;
            }
         }
         else if(value instanceof Integer){
            if(value!=null){
                return Double.valueOf(value);
            }
            else return (Object)0;
         }
          
         else return null;
       }
       if(reqdatatype=='ID'){
            if(value!=null){
                String valueStr = String.valueOf(value);
                return valueStr;
            }
              
         
          
         else return null;
       }
       
       return null;
    }
    public static String getInputValueAsString(Object value){

        String str = String.valueOf(value);
        if(String.isBlank(str)){
           str=  null;
        }
        else{
          str = ''+str;
        }
      return str;
    }

    private static SObject getMetadata() {
        String metadataJSON = '[\n' +
                '  {\n' +
                '    "Base_URL__c": "https://api.cognisure.ai",\n' +
                '    "DeveloperName": "api_details",\n' +
                '    "Id": "m0PHp0000004mUPMAY",\n' +
                '    "Label": "api-details",\n' +
                '    "Language": "en_US",\n' +
                '    "MasterLabel": "api-details",\n' +
                '    "NamespacePrefix": null,\n' +
                '    "Password__c": "{!$Credential.Cognisure.password}",\n' +
                '    "QualifiedApiName": "api_details",\n' +
                '    "Token_Response_Key__c": "access_token",\n' +
                '    "Token_URL__c": "/token",\n' +
                '    "Upload_API_Endpoint__c": "/api/submission/upload?id={0}&submissionName={1}",\n' +
                '    "Username__c": "{!$Credential.Cognisure.username}",\n' +
                '    "Common_JSON_URL__c": "/api/submission/commonjson/?id={0}",\n' +
                '    "Email_Message_Query_Plugin__c": "CognisureAPI.MessageQueryBuilder",\n' +
                '    "Submission_Query_Plugin__c": "CognisureAPI.SubmissionQueryBuilder",\n' +
                '    "Upload_API_Plugin__c": "CognisureAPI.EmailAttachmentForm64",\n' +
                '    "NamedCredentail__c": "cognisureai"\n' +
                '  }\n' +
                ']';
        List<Sobject> metadataList = (List<Cognisureapi__mdt>) JSON.deserialize(metadataJSON, List<Cognisureapi__mdt>.class);
        return metadataList[0];
    }

}
/**
 *  
 * \\
 * 
 String strb1;
 String strb2='FAlSe';
 String strb3='True';
 String strb4='TRue';

 Boolean dt = null;
 Object o =  (Object)dt;

 String str = ProcessSubmissionResponse.getInputValueAsString(o);
 Boolean b = Boolean.valueOf(str);
 System.debug(LoggingLevel.Debug, b);


 * 
 */