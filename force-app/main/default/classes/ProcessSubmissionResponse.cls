/**
 * 
 * 
 String NAMESPACEPREFIX= 'csundrwrtr__';
 String caseFieldAPI = NAMESPACEPREFIX+'case__c';
 Submission__c s = [select Id,csundrwrtr__Case__c from Submission__c limit 1];
Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String>{'Submission__c'});
Schema.DescribeSObjectResult descResult0 = descResult[0];
System.debug(LoggingLevel.Debug, descResult0.fields.getMap().get(caseFieldAPI));
Schema.SobjectField fieldToken_case = descResult0.fields.getMap().get(caseFieldAPI);
System.debug((String)s.get(fieldToken_case));

Schema.DescribeSObjectResult dsr = Cognisureapi__mdt.sObjectType.getDescribe();
String namespacePrefix = dsr.getName().remove(dsr.getLocalName());
System.debug(namespacePrefix);



 */


public with sharing class ProcessSubmissionResponse {
    Class CustomResponseException Extends Exception{}
    //Static String NAMESPACEPREFIX=CognisureAPI_Util.NAMESPACEPREFIX;
    
    public ProcessSubmissionResponse() {
        
    }

    /*public static String NAMESPACEPREFIX{
        get{
            if(NAMESPACEPREFIX==null){
                Schema.DescribeSObjectResult dsr = Cognisureapi__mdt.sObjectType.getDescribe();
                String namespacePrefix0 = dsr.getName().remove(dsr.getLocalName());
                System.debug(LoggingLevel.DEBUG, namespacePrefix0);
                
            }
            return NAMESPACEPREFIX;
        }
        private set;
    }*/
    
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
    
    public static Map<String,List<Common_JSON_Mapping_Setting__mdt>> getResponseMapping(){
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String>{'Common_JSON_Mapping_Setting__mdt'});
        Map<String,List<Common_JSON_Mapping_Setting__mdt>> mappingRecordsIndexBy_Seq = new Map<String,List<Common_JSON_Mapping_Setting__mdt>>();
                if(descResult[0].isAccessible() && descResult[0].isQueryable()){
                    for(Common_JSON_Mapping_Setting__mdt responseMappingmdt: Common_JSON_Mapping_Setting__mdt.getAll().Values()){
                        //[Select Id, csundrwrtr__Active__c, csundrwrtr__Order__c, csundrwrtr__Sobject__c, csundrwrtr__Field__c, csundrwrtr__ResponseFieldKey__c, csundrwrtr__ResponseObjectKey__c,csundrwrtr__Default_Value__c from csundrwrtr__Common_JSON_Mapping_Setting__mdt
                         //where csundrwrtr__Active__c =true order by csundrwrtr__Order__c Asc]
                            Boolean isActive = (Boolean)responseMappingmdt.get('Active__c');
                            if(isActive){
                                Decimal mappingSequenceDecimal = (Decimal)responseMappingmdt.get('Order__c');
                                String mappingSequence = String.valueOf(mappingSequenceDecimal);
                                if(!mappingRecordsIndexBy_Seq.containsKey(mappingSequence)){
                                    mappingRecordsIndexBy_Seq.put(mappingSequence, new List<Common_JSON_Mapping_Setting__mdt>());
                                }
                                mappingRecordsIndexBy_Seq.get(mappingSequence).add(responseMappingmdt);
                            }
                    }
                }
                else {
                    Throw New CustomResponseException('Mapping Data is Not accessible');
                }
        
        //System.debug(LoggingLevel.DEBUG,JSON.serialize(mappingRecordsIndexBy_RespObjects));
        return mappingRecordsIndexBy_Seq;
    }
    /*
    Delete [Select id,name from Claim where createdDate = Today]
        ProcessSubmissionResponse.processJSONResponse('','a00DS00000Bz1m6YAB');
    */
    public static void processJSONResponse(String JSONRepsonse, Id submissionSobjId){
        
        Map<String,Id> parentSobjectIds = new Map<String,Id>(); 

        Schema.DescribeSObjectResult[] descResult_submission = Schema.describeSObjects(new List<String>{'Submission__c'});
        Schema.DescribeSObjectResult descRes = descResult_submission[0].getSObjectType().getDescribe();
        String namespacePrefix0 = descRes.getName().remove(descRes.getLocalName());

        Sobject SubsmsisonSobjRecord ;
        if(descResult_submission[0].isAccessible() && descResult_submission[0].isQueryable()){
            String caseFieldAPI = namespacePrefix0+'Case__c';
            System.debug(LoggingLevel.DEBUG, caseFieldAPI);
            SubsmsisonSobjRecord = [Select Id,case__c from Submission__c where Id =:submissionSobjId];
            Schema.SobjectField fieldToken_case = descRes.fields.getMap().get(caseFieldAPI);
            //System.debug(LoggingLevel.DEBUG, descRes.fields.getMap());
            System.debug( fieldToken_case);

            Schema.DescribeFieldResult dfr_case = fieldToken_case.getDescribe();
            if(dfr_case.accessible ){
                Id caseId = SubsmsisonSobjRecord.get(caseFieldAPI)!=null?String.valueOf(SubsmsisonSobjRecord.get(caseFieldAPI)):'';
                if(!String.isBlank(caseId)){
                    parentSobjectIds.put('caseid',caseId);
                }
            }
            else{
                Throw New CustomResponseException('Case field on Submission Object is Not Accessible. Check permissions');
            }
            
        }
        else{
            Throw New CustomResponseException('Submission record is not accessible. Check permissions on Submission Object.');
        }
        
        
        //System.debug(LoggingLevel.debug, '-->'+submissionResponseJson);
        
        //Map<String,String> SobjectMapping = getSobjectMapping();
        //comes from static resouce mapping: CustomeObject => Response Element
        //StaticResource SR = [Select id,name,body from StaticResource where Name = 'submissionrespunformatted'];
        //String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        String submissionResponseJson =  JSONRepsonse;
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(submissionResponseJson);
        String dataJson = (String)m.get('data');
        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(dataJson);
        // Parse JSON response to build a map from API version numbers to labels
        String SobjectTypesCSV = getSobjectsForDML();
        if(String.isNotBlank(SobjectTypesCSV)){
            Set<String> SobjectTypeList = new Set<String>(SobjectTypesCSV.split(','));
            System.debug(LoggingLevel.DEBUG, 'Sobjects being processed:'+SobjectTypeList);
            Map<String,List<Common_JSON_Mapping_Setting__mdt>>  mappingRecordsIndexBy_Seq= getResponseMapping();
            //System.debug(LoggingLevel.DEBUG,JSON.serialize(mappingRecordsIndexBy_RespObjects));

            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(
                new List<String>(SobjectTypeList));
            Map<String,Schema.DescribeSObjectResult> descResMap = new Map<String,Schema.DescribeSObjectResult>(); 
            Map<String,List<Sobject>> SobjectsRecords_BySobjectString= new Map<String,List<Sobject>>();
            for(Schema.DescribeSObjectResult descResult_iter:descResult){
                descResMap.put(descResult_iter.getName(),descResult_iter);
            } 
            
            for(String seq: mappingRecordsIndexBy_Seq.keySet()){
                List<Common_JSON_Mapping_Setting__mdt> mappingrecList = mappingRecordsIndexBy_Seq.get(seq);
                List<Sobject> sobjectList= new List<Sobject>();
                        Common_JSON_Mapping_Setting__mdt responseMappingmdt= mappingrecList[0];
                        String responseObjectStr = (String)responseMappingmdt.get('ResponseObjectKey__c');
                        String sobjectTypeStr = (String)responseMappingmdt.get('Sobject__c');
                        
                        if(SobjectTypeList.contains(sobjectTypeStr)){
                        System.debug(LoggingLevel.Debug, 'Reponse Keys:'+JSON.serialize(m1.keySet()));
                        List<Object> m3 = (List<Object>)m1.get(responseObjectStr);
                        
                        if(m1.containsKey(responseObjectStr)){
                            if(responseObjectStr=='Account_Level_Info'){
                                if(m3.size()>0)
                                   m3=new List<Object>{m3[0]};
                            }
                            sobjectList= processSobjectInfo( m3, descResMap,mappingrecList);
                                
                            addSobjectListToMap(sobjectList,SobjectsRecords_BySobjectString);
                        }
                    }
            }
            
            InsertFSCData(SobjectsRecords_BySobjectString,  descResMap,parentSobjectIds);
        }
        
    }

    

    public static void InsertFSCData(Map<String,List<Sobject>> SobjectsRecords_BySobjectString,Map<String,Schema.DescribeSObjectResult> descResMap,  Map<String,Id> parentSobjectIds){
        
        String SobjectTypeString_Account = 'Account';
        List<Account> accountList = SobjectsRecords_BySobjectString.get(SobjectTypeString_Account);
        String AccountName = (String)accountList[0].get('Name');
        accountList = [Select Id,name from Account where name =:AccountName limit 1];
        if(accountList.size()>0){
            parentSobjectIds.put('accountid',accountList[0].Id);
        }
        else{
            if(accountList.size()==0){
                accountList = SobjectsRecords_BySobjectString.get(SobjectTypeString_Account);
                List<Id> Ids = upsertOrInsertSFRecords(accountList,'Account',descResMap.get(SobjectTypeString_Account));
                parentSobjectIds.put('accountid',Ids[0]);
            }
        }
        SobjectsRecords_BySobjectString.remove(SobjectTypeString_Account);
        
        // Insert rest of the data.
        for(String sobjectTypeStr: SobjectsRecords_BySobjectString.keySet()){
            Schema.DescribeSObjectResult descRes = descResMap.get(sobjectTypeStr);
            List<Sobject> sobjectList = SobjectsRecords_BySobjectString.get(sobjectTypeStr);
            // for assigning parent relationships.
            assignSObjectSpecificFields( SobjectTypeStr, sobjectList, parentSobjectIds);
            //called multiple times per collection of sobject records. for example claim, customerproperty etc.
            List<Id> Ids = upsertOrInsertSFRecords(sobjectList, sobjectTypeStr, descRes);
            
        }

    }

    public static void addSobjectListToMap(List<Sobject> sobjectList, Map<String,List<Sobject>> SobjectsRecords_BySobjectString){
      
        String sobjectTypeStr = sobjectList[0].getSObjectType().toString();
        if(!SobjectsRecords_BySobjectString.containsKey(sobjectTypeStr)){
            SobjectsRecords_BySobjectString.put(sobjectTypeStr, new List<Sobject>());
        }
        SobjectsRecords_BySobjectString.get(sobjectTypeStr).addAll(sobjectList);
    }
    
    /*public static void processResponseElements(String jsonResponseElement){
        String jsonResponseElement2 = '{"Insured_Nm": "Carver & Carver Plumbing Inc.","Policy_Effectivedate": "09/12/2019","Policy_Expirydate": "09/12/2020","Policy_Nbr": "40466","Amount":1000,"Amount2":1000.0}';
        JSONParser parser = JSON.createParser(jsonResponseElement2);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                System.debug(LoggingLevel.DEBUG,parser.getText());
                parser.nextToken();
                System.debug(LoggingLevel.DEBUG,parser.getText());
                
            }
            
        }
        // if(version != null && String.isNotEmpty(label)) {
        //     apiVersionToReleaseNameMap.put(version, label);
        //     version = null;
        //     label = null; 
        // }
        
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
            
            
          if( descRes.isAccessible() && (descRes.isCreateable() || descRes.isUpdateable())){
            //System.debug(LoggingLevel.Debug,'@@@'+descResMap.get(sobjectTypeStr).Fields.getMap().get('Cognisure_External_Id__c'));
            String externalIdToken = sobjectExternalIdInfo.get(sobjectTypeStr);
            Schema.SObjectField fieldToken2 = descRes.Fields.getMap().get(externalIdToken);
            Database.UpsertResult[] results ;
            if(fieldToken2!=null){
                //System.debug(LoggingLevel.DEBUG, 'Before Upserting Records:'+sobjectTypeStr);
                results = Database.upsert(sobjList,fieldToken2);
                //System.debug(LoggingLevel.ERROR, JSON.serialize(results));
            }
            // Not supporting upserts yet as there are not external Ids.
            //Upsert claims Name;
         }
         else {
            Throw New CustomResponseException('Check Permissions on Object '+sobjectTypeStr);
         }
        }
        else {
            //System.debug(LoggingLevel.DEBUG, 'Before Inserting Records'+sobjectTypeStr);
            Ids = new List<Id>();
            if( descRes.isAccessible() && descRes.isCreateable()){
                Database.SaveResult[] srList = Database.insert(sobjList, false);
                for(Database.SaveResult sr:srList ){
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Record. Record ID: ' + sr.getId());
                        Ids.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Record fields that affected this error: ' + err.getFields());
                            Throw New CustomResponseException('Error Occured:'+err.getStatusCode() + ': ' + err.getMessage()+':'+err.getFields()+':Sobject : '+sobjectTypeStr);
                        }
                    }
                }
            }
            else{
                Throw New CustomResponseException('Check Permissions on Object '+sobjectTypeStr);
            }
            
        }
        
        return Ids;
    }
    
    public static Map<String,String> getSobjectExternalIdInfo(){
        StaticResource SR =  fsc_Sobject_ExternalId_Info;
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
    
    
    private static List<Sobject> processSobjectInfo(List<Object> respObjList,  Map<String,Schema.DescribeSObjectResult> descSobjResMap, List<Common_JSON_Mapping_Setting__mdt> mappingList){
        
        
        //DescribeSObjectResult descSobjRes = descResMap.get(sobjectType);
        //System.debug(LoggingLevel.Debug, 'respObjList:'+JSON.serialize(respObjList));
        System.debug(LoggingLevel.Debug, 'respObjList size'+respObjList.size());
        List<Sobject> sobjList = new List<Sobject>();

        for(Object obj:respObjList){
            //System.debug(LoggingLevel.debug, 'obj: '+JSON.serialize(obj));
            Sobject sobj = populateSobjectWithFieldValues(descSobjResMap,obj, mappingList);
            sobjList.add(sobj);
        }
        populateSobjectDefaults(sobjList,descSobjResMap);

        String commonJSONResponseHandlerInstance = cognisureapimetadata.get('Record_Field_Setter_Plugin__c')!=null?(String) cognisureapimetadata.get('Record_Field_Setter_Plugin__c'):'CognisureAPI.sobjectrecordsinterceptor';
        CognisureAPI.CommonJSONResponseHandler cjrh  = (CognisureAPI.CommonJSONResponseHandler) Type.forName(commonJSONResponseHandlerInstance).newInstance();
        cjrh.overwriteSObjectFieldValues(sobjList[0].getSObjectType() ,sobjList);
        return sobjList;
    } 
    
    public static void populateSobjectDefaults( List<Sobject> sobjList,Map<String,Schema.DescribeSObjectResult> descSobjResMap){
        String Sobjectname = sobjList[0].getSObjectType().toString();
        StaticResource Sr = fsc_sobject_field_defaults;
        String DefaultfieldMapStr =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        Schema.DescribeSObjectResult descSobjRes = descSobjResMap.get(Sobjectname);
        Map<String,Object> DefaultfieldMapByObject = (Map<String, Object>)JSON.deserializeUntyped(DefaultfieldMapStr);
        Map<String,Object> DefaultsMap_Sobject = (Map<String,Object>)DefaultfieldMapByObject.get(Sobjectname);
        
        if(descSobjRes.isAccessible() && descSobjRes.isCreateable()){
            if(DefaultsMap_Sobject!=null){
                for(Sobject sobj:sobjList){
                    String Sobjname = sobj.getSObjectType().toString();
                    if(Sobjname==Sobjectname){
                        for(String Str : DefaultsMap_Sobject.keySet()){
                                Schema.SobjectField fieldToken = descSobjRes.fields.getMap().get(Str);
                                Schema.DescribeFieldResult dfr = fieldToken.getDescribe();
                                if(dfr.isAccessible() && dfr.isUpdateable()){
                                    if(!Sobj.isSet(Str)    ) {
                                
                                        Object o = (Object)DefaultsMap_Sobject.get(Str);
                                        System.debug(LoggingLevel.Debug, 'fieldName: '+dfr.getName()+': Type: '+dfr.getSoapType());
                                        o=convertFieldValueToObject(dfr.getName(), o,String.valueOf(dfr.getSoapType()));
                                        System.debug(LoggingLevel.Debug, ''+o);
                                        sobj.put(Str,o);
                                    
                                    }
                                }
                            
                            
                        }
                    }
                    
                }
                
            }
        }
        
        
        
    }
    
    public static Sobject populateSobjectWithFieldValues(Map<String,Schema.DescribeSObjectResult> descSobjResMap, Object resp_obj,  List<Common_JSON_Mapping_Setting__mdt> mappingList){
        Map<String,Object> res_obj_field_values = (Map<String,Object>)resp_obj;

        Common_JSON_Mapping_Setting__mdt mapping0 = mappingList[0];
        System.debug(LoggingLevel.DEBUG, JSON.serialize(mapping0));

        String sobjectTypeStr = (String)mapping0.get('Sobject__c');
        System.debug(LoggingLevel.DEBUG, sobjectTypeStr);
        
        Schema.DescribeSObjectResult descSobjRes=  descSobjResMap.get(sobjectTypeStr);
        Sobject sobj= descSobjRes.getSObjectType().newSObject();
        for(Common_JSON_Mapping_Setting__mdt mapping: mappingList){
            
            String sobjFieldStr = (String)mapping.get('Field__c');
            System.debug(LoggingLevel.Debug,'Definiton Key:'+sobjFieldStr);
            //System.debug(LoggingLevel.DEBUG,'@causeofloss'+ descSobjRes.fields.getMap().get(sobjFieldStr).getDescribe());
            //System.debug(LoggingLevel.DEBUG, descSobjRes.fields.getMap().get('csundrwrtr__'+sobjFieldStr).getDescribe());
            if(descSobjRes.fields.getMap().containsKey(sobjFieldStr)){
                Schema.SobjectField fieldToken = descSobjRes.fields.getMap().get(sobjFieldStr);
                Schema.DescribeFieldResult dfr = fieldToken.getDescribe();
                if(dfr.isAccessible() && dfr.isUpdateable()){
                    String definitionMap_SobjFieldValue = (String)mapping.get('ResponseFieldKey__c');
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

        return sobj;
        
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