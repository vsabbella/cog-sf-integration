public with sharing class ProcessSubmissionResponse {
    Class CustomResponseException Extends Exception {
    }
    public ProcessSubmissionResponse() {

    }
    private static sobject cognisureapimetadata {
        get {
            if (cognisureapimetadata == null) {
                cognisureapimetadata = (Sobject) Cognisureapi__mdt.getInstance('api_details');
                if (cognisureapimetadata == null) {
                    Throw New CustomResponseException('Custom Metadata setting api_details not found.');
                }
            }
            return cognisureapimetadata;
        }
        private set;
    }
    private Static StaticResource fsc_sobject_field_defaults {
        get {
            if (fsc_sobject_field_defaults == null) {
                List<StaticResource> srList = [Select Id, name, body from StaticResource where Name = :(String) cognisureapimetadata.get('Field_Default_Definition__c')];
                if (srList.size() == 0) {
                    Throw New CustomResponseException('Default Definiton Static Resource Not Found.');
                }
                if (srList.size() > 0) {
                    fsc_sobject_field_defaults = srList[0];
                }
            }
            return fsc_sobject_field_defaults;
        }
        private set;
    }
    private Static StaticResource fsc_Sobject_ExternalId_Info {
        get {
            if (fsc_Sobject_ExternalId_Info == null) {
                List<StaticResource> srList = [Select Id, name, body from StaticResource where Name = :(String) cognisureapimetadata.get('Field_External_Id_Definition__c')];
                if (srList.size() > 0) {
                    fsc_Sobject_ExternalId_Info = srList[0];
                }
            }
            return fsc_Sobject_ExternalId_Info;
        }
        private set;
    }

    private static Map<String, List<Common_JSON_Mapping_Setting__mdt>> getResponseMapping() {
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String>{
                'Common_JSON_Mapping_Setting__mdt'
        });
        Map<String, List<Common_JSON_Mapping_Setting__mdt>> mappingRecordsIndexBy_Seq = new Map<String, List<Common_JSON_Mapping_Setting__mdt>>();
        if (descResult[0].isAccessible() && descResult[0].isQueryable()) {
            for (Common_JSON_Mapping_Setting__mdt responseMappingmdt : Common_JSON_Mapping_Setting__mdt.getAll().Values()) {
                Boolean isActive = (Boolean) responseMappingmdt.get('Active__c');
                if (isActive) {
                    Decimal mappingSequenceDecimal = (Decimal) responseMappingmdt.get('Order__c');
                    String mappingSequence = String.valueOf(mappingSequenceDecimal);
                    if (!mappingRecordsIndexBy_Seq.containsKey(mappingSequence)) {
                        mappingRecordsIndexBy_Seq.put(mappingSequence, new List<Common_JSON_Mapping_Setting__mdt>());
                    }
                    mappingRecordsIndexBy_Seq.get(mappingSequence).add(responseMappingmdt);
                }
            }
        } else {
            Throw New CustomResponseException('Mapping Data is Not accessible');
        }

        return mappingRecordsIndexBy_Seq;
    }
    /*
    Delete [Select id,name from Claim where createdDate = Today]
    //comes from static resouce mapping: CustomeObject => Response Element
    StaticResource SR = [Select id,name,body from StaticResource where Name = 'submissionrespunformatted'];
    String submissionResponseJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
    String jsonResponsemock = CommonJSONResponseTestData.getCommonjsonAPIResp_passwith1recordeach();
    ProcessSubmissionResponse.processJSONResponse(jsonResponsemock,'a00DS00000Bz1m6YAB');
    */
    public static void processJSONResponse(String JSONRepsonse, Id submissionSobjId) {

        Map<String, Id> parentSobjectIds = new Map<String, Id>();

        String namespacePrefix = CognisureAPI_Util.getNameSpacePrefix();
        if (String.isBlank(namespacePrefix)) {
            Throw new CustomResponseException('Namespace is blank');
        }

        if (Submission__c.SObjectType.getDescribe().isAccessible()) {
            Sobject SubsmsisonSobjRecord ;
            String caseFieldAPI = namespacePrefix + 'Case__c';
            System.debug(LoggingLevel.DEBUG, caseFieldAPI);

            //Schema.SobjectField fieldToken_case = Schema.SObjectType.Submission__c.fields.Case__c;
            //Schema.DescribeFieldResult dfr_case = fieldToken_case.getDescribe();
            if (Schema.SObjectType.Submission__c.fields.Case__c.isAccessible()) {
                //Id submissionSobjId2 = String.escapeSingleQuotes(submissionSobjId);
                SubsmsisonSobjRecord = [Select Id, case__c from Submission__c where Id = :submissionSobjId];
                Id caseId = SubsmsisonSobjRecord.get(caseFieldAPI) != null ? String.valueOf(SubsmsisonSobjRecord.get(caseFieldAPI)) : '';
                if (!String.isBlank(caseId)) {
                    parentSobjectIds.put('caseid', caseId);
                }
            } else {
                Throw New CustomResponseException('Case field on Submission Object is Not Accessible. Check permissions');
            }

        } else {
            Throw New CustomResponseException('Submission record is not accessible. Check permissions on Submission Object.');
        }

        String submissionResponseJson = JSONRepsonse;
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(submissionResponseJson);
        String dataJson = (String) m.get('data');
        Map<String, Object> m1 = (Map<String, Object>) JSON.deserializeUntyped(dataJson);
        String SobjectTypesCSV = getSobjectsForDML();
        if (String.isNotBlank(SobjectTypesCSV)) {
            Set<String> SobjectTypeList = new Set<String>(SobjectTypesCSV.split(','));
            System.debug(LoggingLevel.DEBUG, 'Sobjects being processed:' + SobjectTypeList);
            Map<String, List<Common_JSON_Mapping_Setting__mdt>> mappingRecordsIndexBy_Seq = getResponseMapping();

            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(
                    new List<String>(SobjectTypeList));
            Map<String, Schema.DescribeSObjectResult> descResMap = new Map<String, Schema.DescribeSObjectResult>();
            Map<String, List<Sobject>> SobjectsRecords_BySobjectString = new Map<String, List<Sobject>>();
            for (Schema.DescribeSObjectResult descResult_iter : descResult) {
                descResMap.put(descResult_iter.getName(), descResult_iter);
            }

            for (String seq : mappingRecordsIndexBy_Seq.keySet()) {
                List<Common_JSON_Mapping_Setting__mdt> mappingrecList = mappingRecordsIndexBy_Seq.get(seq);
                List<Sobject> sobjectList = new List<Sobject>();
                Common_JSON_Mapping_Setting__mdt responseMappingmdt = mappingrecList[0];
                String responseObjectStr = (String) responseMappingmdt.get('ResponseObjectKey__c');
                String sobjectTypeStr = (String) responseMappingmdt.get('Sobject__c');

                if (SobjectTypeList.contains(sobjectTypeStr)) {
                    System.debug(LoggingLevel.Debug, 'Reponse Keys:' + JSON.serialize(m1.keySet()));
                    List<Object> m3 = (List<Object>) m1.get(responseObjectStr);

                    if (m1.containsKey(responseObjectStr)) {
                        if (responseObjectStr == 'Account_Level_Info') {
                            if (m3.size() > 0)
                                m3 = new List<Object>{
                                        m3[0]
                                };
                        }
                        sobjectList = processSobjectInfo(m3, descResMap, mappingrecList);

                        addSobjectListToMap(sobjectList, SobjectsRecords_BySobjectString);
                    }
                }
            }

            InsertFSCData(SobjectsRecords_BySobjectString, descResMap, parentSobjectIds);
        }

    }


    public static void InsertFSCData(Map<String, List<Sobject>> SobjectsRecords_BySobjectString, Map<String, Schema.DescribeSObjectResult> descResMap, Map<String, Id> parentSobjectIds) {


        String SobjectTypeString_Account = 'Account';
        //Schema.DescribeSObjectResult descRes_Account = descResMap.get(SobjectTypeString_Account);
        List<Account> accountList = SobjectsRecords_BySobjectString.get(SobjectTypeString_Account);

        if (Account.SObjectType.getDescribe().isAccessible()) {
            //Schema.SobjectField fieldToken_Name = descRes_Account.fields.getMap().get('Name');
            //Schema.DescribeFieldResult dfr_Name = fieldToken_Name.getDescribe();
            if (Schema.SObjectType.Account.fields.Name.isAccessible()) {

                String AccountName = (String) accountList[0].get('Name');
                String AccountName2 = String.escapeSingleQuotes(AccountName);
                accountList = [Select Id, name from Account where name = :AccountName2 limit 1];
                if (accountList.size() > 0) {
                    parentSobjectIds.put('accountid', accountList[0].Id);
                } else {
                    if (accountList.size() == 0) {
                        accountList = SobjectsRecords_BySobjectString.get(SobjectTypeString_Account);
                        List<Id> Ids = upsertOrInsertSFRecords(accountList, SobjectTypeString_Account, descResMap.get(SobjectTypeString_Account));
                        parentSobjectIds.put('accountid', Ids[0]);
                    }
                }
            } else {
                Throw New CustomResponseException('Account Name is not accessible. Check Permissions.');
            }


        }
        SobjectsRecords_BySobjectString.remove(SobjectTypeString_Account);

        // Insert rest of the data.
        for (String sobjectTypeStr : SobjectsRecords_BySobjectString.keySet()) {
            Schema.DescribeSObjectResult descRes = descResMap.get(sobjectTypeStr);
            List<Sobject> sobjectList = SobjectsRecords_BySobjectString.get(sobjectTypeStr);
            // for assigning parent relationships.
            assignSObjectSpecificFields(SobjectTypeStr, sobjectList, parentSobjectIds);
            //called multiple times per collection of sobject records. for example claim, customerproperty etc.
            List<Id> Ids = upsertOrInsertSFRecords(sobjectList, sobjectTypeStr, descRes);

        }


    }

    public static void addSobjectListToMap(List<Sobject> sobjectList, Map<String, List<Sobject>> SobjectsRecords_BySobjectString) {

        String sobjectTypeStr = sobjectList[0].getSObjectType().toString();
        if (!SobjectsRecords_BySobjectString.containsKey(sobjectTypeStr)) {
            SobjectsRecords_BySobjectString.put(sobjectTypeStr, new List<Sobject>());
        }
        SobjectsRecords_BySobjectString.get(sobjectTypeStr).addAll(sobjectList);
    }


    private static String getSobjectsForDML() {
        sobject cognisureapimetadata = (Sobject) Cognisureapi__mdt.getInstance('api_details');
        return (String) cognisureapimetadata.get('Objects_To_Create__c');
    }

    private static void assignSObjectSpecificFields(String SobjectTypeStr, List<Sobject> sobjectList, Map<String, String> parentSobjectIds) {

        if (sobjectTypeStr == 'Claim') {
            for (Sobject sobj0 : sobjectList) {
                if (parentSobjectIds.containsKey('accountid')) {
                    sobj0.put('AccountId', parentSobjectIds.get('accountid'));
                }
                if (parentSobjectIds.containsKey('caseid')) {
                    sobj0.put('CaseId', parentSobjectIds.get('caseid'));
                }
            }

        } else if (sobjectTypeStr == 'CustomerProperty') {
            for (Sobject sobj0 : sobjectList) {
                sobj0.put('PrimaryOwnerId', parentSobjectIds.get('accountid'));
            }

        }
    }

    private static List<Id> upsertOrInsertSFRecords(List<Sobject> sobjList, String sobjectTypeStr, Schema.DescribeSObjectResult descRes) {
        List<Id> Ids;
        Map<String, String> sobjectExternalIdInfo = getSobjectExternalIdInfo();

        if (sobjectExternalIdInfo.containsKey(sobjectTypeStr) && !String.isBlank(sobjectExternalIdInfo.get(sobjectTypeStr))) {


            if (descRes.isAccessible() && (descRes.isCreateable() || descRes.isUpdateable())) {
                //System.debug(LoggingLevel.Debug,'@@@'+descResMap.get(sobjectTypeStr).Fields.getMap().get('Cognisure_External_Id__c'));
                String externalIdToken = sobjectExternalIdInfo.get(sobjectTypeStr);
                Schema.SObjectField fieldToken2 = descRes.Fields.getMap().get(externalIdToken);
                Database.UpsertResult[] results ;
                if (fieldToken2 != null) {
                    //System.debug(LoggingLevel.DEBUG, 'Before Upserting Records:'+sobjectTypeStr);
                    results = Database.upsert(sobjList, fieldToken2);
                    //System.debug(LoggingLevel.ERROR, JSON.serialize(results));
                }
                // Not supporting upserts yet as there are not external Ids.
                //Upsert claims Name;
            } else {
                Throw New CustomResponseException('Check Permissions on Object ' + sobjectTypeStr);
            }
        } else {
            Ids = new List<Id>();
            if (descRes.isAccessible() && descRes.isCreateable()) {
                Database.SaveResult[] srList = Database.insert(sobjList, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Record. Record ID: ' + sr.getId());
                        Ids.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors                
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Record fields that affected this error: ' + err.getFields());
                            Throw New CustomResponseException('Error Occured:' + err.getStatusCode() + ': ' + err.getMessage() + ':' + err.getFields() + ':Sobject : ' + sobjectTypeStr);
                        }
                    }
                }
            } else {
                Throw New CustomResponseException('Check Permissions on Object ' + sobjectTypeStr);
            }

        }

        return Ids;
    }

    private static Map<String, String> getSobjectExternalIdInfo() {
        StaticResource SR = fsc_Sobject_ExternalId_Info;
        String submissionResponseJson = EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        Map<String, String> m = (Map<String, String>) JSON.deserialize(submissionResponseJson, Map<String, String>.class);
        return m;

    }


    private static List<Sobject> processSobjectInfo(List<Object> respObjList, Map<String, Schema.DescribeSObjectResult> descSobjResMap, List<Common_JSON_Mapping_Setting__mdt> mappingList) {
        System.debug(LoggingLevel.Debug, 'respObjList size' + respObjList.size());
        List<Sobject> sobjList = new List<Sobject>();

        for (Object obj : respObjList) {
            Sobject sobj = populateSobjectWithFieldValues(descSobjResMap, obj, mappingList);
            sobjList.add(sobj);
        }
        populateSobjectDefaults(sobjList, descSobjResMap);

        String commonJSONResponseHandlerInstance = cognisureapimetadata.get('Record_Field_Setter_Plugin__c') != null ? (String) cognisureapimetadata.get('Record_Field_Setter_Plugin__c') : 'CognisureAPI.sobjectrecordsinterceptor';
        CognisureAPI.CommonJSONResponseHandler cjrh = (CognisureAPI.CommonJSONResponseHandler) Type.forName(commonJSONResponseHandlerInstance).newInstance();
        cjrh.overwriteSObjectFieldValues(sobjList[0].getSObjectType(), sobjList);
        return sobjList;
    }

    private static void populateSobjectDefaults(List<Sobject> sobjList, Map<String, Schema.DescribeSObjectResult> descSobjResMap) {
        String Sobjectname = sobjList[0].getSObjectType().toString();
        StaticResource Sr = fsc_sobject_field_defaults;
        String DefaultfieldMapStr = EncodingUtil.base64Decode(EncodingUtil.base64Encode(sr.body)).toString();
        Schema.DescribeSObjectResult descSobjRes = descSobjResMap.get(Sobjectname);
        Map<String, Object> DefaultfieldMapByObject = (Map<String, Object>) JSON.deserializeUntyped(DefaultfieldMapStr);
        Map<String, Object> DefaultsMap_Sobject = (Map<String, Object>) DefaultfieldMapByObject.get(Sobjectname);

        if (descSobjRes.isAccessible() && descSobjRes.isCreateable()) {

            if (DefaultsMap_Sobject != null) {
                for (Sobject sobj : sobjList) {
                    String Sobjname = sobj.getSObjectType().toString();
                    if (Sobjname == Sobjectname) {
                        for (String Str : DefaultsMap_Sobject.keySet()) {
                            Schema.SobjectField fieldToken = descSobjRes.fields.getMap().get(Str);
                            Schema.DescribeFieldResult dfr = fieldToken.getDescribe();
                            System.debug(LoggingLevel.DEBUG, 'Setting Default for ' + Sobjectname + ' field: ' + dfr.getName());
                            System.debug(LoggingLevel.DEBUG, 'Set Value on Field:' + sobj.get(dfr.getName()));
                            System.debug(LoggingLevel.DEBUG, 'field is set:' + Sobj.isSet(Str));

                            if (dfr.isAccessible() && dfr.isUpdateable()) {
                                if (!Sobj.isSet(Str)) {
                                    System.debug(LoggingLevel.DEBUG, 'String ::' + Str);
                                    Object o = (Object) DefaultsMap_Sobject.get(Str);
                                    System.debug(LoggingLevel.Debug, 'fieldName: ' + dfr.getName() + ': Type: ' + dfr.getSoapType());
                                    o = convertFieldValueToObject(dfr.getName(), o, String.valueOf(dfr.getSoapType()));
                                    System.debug(LoggingLevel.Debug, 'Default Value for ' + Sobjectname + ':' + dfr.getName() + ':' + String.ValueOf(o));
                                    sobj.put(Str, o);

                                }
                            }
                        }
                    }

                }

            }
        }
    }
    // from response, instantiate an sobject per every entry of response key object.
    private static Sobject populateSobjectWithFieldValues(Map<String, Schema.DescribeSObjectResult> descSobjResMap, Object resp_obj, List<Common_JSON_Mapping_Setting__mdt> mappingList) {
        Map<String, Object> res_obj_field_values = (Map<String, Object>) resp_obj;

        Common_JSON_Mapping_Setting__mdt mapping0 = mappingList[0];
        System.debug(LoggingLevel.DEBUG, JSON.serialize(mapping0));

        String sobjectTypeStr = (String) mapping0.get('Sobject__c');
        System.debug(LoggingLevel.DEBUG, sobjectTypeStr);

        Schema.DescribeSObjectResult descSobjRes = descSobjResMap.get(sobjectTypeStr);
        Sobject sobj = descSobjRes.getSObjectType().newSObject();
        for (Common_JSON_Mapping_Setting__mdt mapping : mappingList) {

            String sobjFieldStr = (String) mapping.get('Field__c');
            System.debug(LoggingLevel.Debug, 'Definiton Key:' + sobjFieldStr);
            if (descSobjRes.fields.getMap().containsKey(sobjFieldStr)) {
                Schema.SobjectField fieldToken = descSobjRes.fields.getMap().get(sobjFieldStr);
                Schema.DescribeFieldResult dfr = fieldToken.getDescribe();
                if (dfr.isAccessible() && dfr.isUpdateable()) {
                    String definitionMap_SobjFieldValue = (String) mapping.get('ResponseFieldKey__c');
                    Object response_obj_fieldValue = res_obj_field_values.get(definitionMap_SobjFieldValue);
                    String response_obj_fieldValueStr = String.valueOf(response_obj_fieldValue);

                    System.debug(LoggingLevel.Debug, 'Definiton Key:' + sobjFieldStr);
                    System.debug(LoggingLevel.Debug, 'Definition value:' + definitionMap_SobjFieldValue);
                    System.debug(LoggingLevel.Debug, 'Definition Response:' + String.valueOf(response_obj_fieldValue));
                    System.debug(LoggingLevel.Debug, 'sobj field value' + Json.serialize(response_obj_fieldValue));
                    if (String.isNotBlank(response_obj_fieldValueStr)) {
                        //donot set field values if the value is blank from the response. Required are failing , if blank, so default are set based on wether fiels is set from response or not. s
                        if (dfr.isUpdateable()) {
                            if (response_obj_fieldValue != null) {
                                Object value = convertFieldValueToObject(dfr.getName(), response_obj_fieldValue, String.valueOf(dfr.getSoapType()));
                                sobj.put(sobjFieldStr, value);
                            }
                        }
                    }
                }

            }
        }

        return sobj;

    }

    private static Object convertFieldValueToObject(String field, Object response_claimfieldValue, String reqdatatype) {

        Object value = response_claimfieldValue;

        if (reqdatatype == 'STRING') {
            if (value instanceof String) {
                return value;
            }
        }
        if (reqdatatype == 'BOOLEAN') {
            if (value instanceof String) {
                String str;
                Boolean b ;
                if (value != null) {
                    str = String.valueOf(value);
                    b = String.isBlank(str) ? Boolean.valueOf(str) : false;
                }

                return (Object) b;
            } else if (value instanceof Boolean) {
                return value;
            } else return false;
        }
        if (reqdatatype == 'DATETIME') {
            if (value instanceof String) {
                if (value != null) {
                    DateTime DT;
                    String dateStr = String.valueOf(value);
                    if (dateStr.contains('T')) {
                        String val = dateStr;
                        DateTime date1 = (DateTime) Json.deserialize('"' + val + '"', DateTime.class);
                        DT = date1;
                    } else {
                        Date assessmentDate;

                        if (!String.isBlank(dateStr)) {
                            assessmentDate = Date.parse(dateStr);//Valuation_Date
                            DT = DateTime.newInstance(assessmentDate.year(), assessmentDate.month(), assessmentDate.day());
                        }
                    }


                    return (Object) DT;
                }

            } else return null;
        }
        if (reqdatatype == 'DATE') {
            if (value instanceof String) {
                if (value != null) {
                    String dateStr = String.valueOf(value);
                    Date d;
                    d = !String.isBlank(dateStr) ? Date.parse(dateStr) : null;//Valuation_Date
                    return (Object) d;
                }

            }

            else return null;
        }
        if (reqdatatype == 'DOUBLE') {// Number, Currency
            if (value instanceof String) {
                if (value != null) {
                    String valueStr = String.valueOf(value);
                    valueStr = valueStr.replaceAll(',', '');
                    valueStr = valueStr.replaceAll('\\$', '');
                    Double d;
                    d = !String.isBlank(valueStr) ? Double.valueOf(valueStr) : null;
                    return (Object) d;
                }
            } else if (value instanceof Integer) {
                if (value != null) {
                    return Double.valueOf(value);
                } else return (Object) 0;
            }

            else return null;
        }
        if (reqdatatype == 'ID') {
            if (value != null) {
                String valueStr = String.valueOf(value);
                return valueStr;
            }


            else return null;
        }

        return null;
    }
    private static String getInputValueAsString(Object value) {

        String str = String.valueOf(value);
        if (String.isBlank(str)) {
            str = null;
        } else {
            str = '' + str;
        }
        return str;
    }

}