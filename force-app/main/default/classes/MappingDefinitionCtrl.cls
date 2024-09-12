/**
 * Created by venkatasabbella on 5/29/24.
 */

public with sharing class MappingDefinitionCtrl {
    private static String cognisure_sffield_defaults(){

        String jsonStr = '{\n' +
                '    \n' +
                '    "Claim" : {\n' +
                '        "IsDrivable":false,\n' +
                '        "Status":"Initial"\n' +
                '    },\n' +
                '    "CustomerProperty" : {\n' +
               // '        "BedroomCount": 3,\n' +
                '        "BuiltUpArea": "1000",\n' +
                //'        "CeilingType": "Conventional",\n' +
                //'        "DwellingType": "Duplex",\n' +
                //'        "EngineDisplacementVolume": null,\n' +
                //'        "FairMarketValue": 100000,\n' +
                //'        "FloorCount": 2,\n' +
                //'        "FloorType": "Ceramic Tile",\n' +
                //'        "FoundationType": "Basement",\n' +
                //'        "GarageType": "Attached",\n' +
                //'        "IsBasementIncluded": false,\n' +
                //'        "IsChimneyIncluded": false,\n' +
                //'        "IsPassedSmogCheck": false,\n' +
                //'        "IsSwimmingPoolIncluded": false,\n' +
                //'        "LotArea": "2000",\n' +
                //'        "PurchaseDate": "01/07/2024",\n' +
                //'        "PurchasePrice": 100000,\n' +
                //'        "RecordTypeId": "012Hp000002F7C0IAK",\n' +
                //'        "RoofType": "Slate",\n' +
                '        "YearBuilt": 2000\n' +
                '    },\n' +
                '    \n' +
                '    "CoverageType" : {\n' +
                //'        "BenefitPaymentFrequency": null,\n' +
                //'        "Category": "Coverage",\n' +
                //'        "CategoryCode": null,\n' +
                //'        "CategoryGroup": "Liability",\n' +
                //'        "CategoryGroupType": "Property Damage",\n' +
                //'        "CategoryGroupTypeValue": "Amount Per Person;Amount Per Occurance",\n' +
                //'        "CoverageCode": null,\n' +
                //'        "DeathBenefitOptionType": null,\n' +
                //'        "DeductibleAmount": 10000,\n' +
                //'        "Description": null,\n' +
                //'        "Discount": null,\n' +
                //'        "EffectiveDate": "2024-01-08T02:36:00.000+0000",\n' +
                //'        "ExpirationDate": "2025-01-08T02:36:00.000+0000",\n' +
                //'        "IncomeOptionType": null,\n' +
                //'        "LimitAmount": 100000,\n' +
                //'        "LimitPercentage": null,\n' +
                //'        "LimitRange": "50/100/50",\n' +
                '        "Name": "Property Coverage",\n' +
                //'        "PremiumAmount": null,\n' +
                //'        "SourceSystem": null,\n' +
                '        "SourceSystemIdentifier": null\n' +
                '      },\n' +
                '    "InsurancePolicy" : \n' +
                '        {\n' +
                //'          "AuditTerm": "Quarterly",\n' +
                //'          "BillingCarrierAccountId": null,\n' +
                //'          "CancellationDate": null,\n' +
                //'          "CancellationReason": null,\n' +
                //'          "CancellationReasonType": null,\n' +
                //'          "CashSurrenderValue": null,\n' +
                //'          "ChangeSubtype": null,\n' +
                //'          "ChangeType": null,\n' +
//                '          "ContractGroupPlanId": null,\n' +
//                '          "CurrentDueAmount": null,\n' +
//                '          "DateRenewed": null,\n' +
//                '          "Discount": null,\n' +
//                '          "EffectiveDate": "2024-01-08T02:39:00.000+0000",\n' +
//                '          "ExpirationDate": "2025-01-08T02:39:00.000+0000",\n' +
//                '          "FinServ__Household__c": null,\n' +
//                '          "FinalRenewalDate": null,\n' +
//                '          "GrossWrittenPremium": null,\n' +
//                '          "HasAnyAutoCoverage": false,\n' +
//                '          "IntermediaryAccountId": null,\n' +
//                '          "IsLoanEligibile": false,\n' +
//                '          "IsRenewedPolicy": false,\n' +
//                '          "NameInsuredId": "001Hp00002k9vo3IAA",\n' +
//                '          "OriginalEffectiveDate": null,\n' +
//                '          "OriginalExpirationDate": null,\n' +
//                '          "OriginalPolicyId": null,\n' +
//                '          "PaidToDate": null,\n' +
//                '          "ParentPolicyId": null,\n' +
//                '          "PastDueAmount": null,\n' +
//                '          "PaymentDueDate": null,\n' +
//                '          "PlanTier": null,\n' +
//                '          "PlanType": null,\n' +
//                '          "PolicyDescription": null,\n' +
//                '          "PolicyName": "AIG-12345",\n' +
//                '          "PolicyTerm": null,\n' +
//                '          "PolicyType": "Business Interruption",\n' +
//                '          "PremiumAmount": null,\n' +
//                '          "PremiumCalculationMethod": null,\n' +
//                '          "PremiumFrequency": null,\n' +
//                '          "PremiumPaymentType": null,\n' +
//                '          "PreviousPremium": null,\n' +
//                '          "PreviousRenewalDate": null,\n' +
//                '          "PriorPolicyId": null,\n' +
//                '          "ProducerId": null,\n' +
//                '          "ProductId": "01tHp00000B3h61IAB",\n' +
//                '          "ReferencePolicyNumber": null,\n' +
//                '          "RenewalChannel": null,\n' +
//                '          "RenewalDate": null,\n' +
//                '          "RenewedFromPolicyId": null,\n' +
//                '          "SaleDate": null,\n' +
//                '          "ServicingOfficeCity": null,\n' +
//                '          "ServicingOfficeCountry": null,\n' +
//                '          "ServicingOfficeGeocodeAccuracy": null,\n' +
//                '          "ServicingOfficeLatitude": null,\n' +
//                '          "ServicingOfficeLongitude": null,\n' +
//                '          "ServicingOfficePostalCode": null,\n' +
//                '          "ServicingOfficeState": null,\n' +
//                '          "ServicingOfficeStreet": null,\n' +
//                '          "SourceOpportunityId": null,\n' +
//                '          "SourceQuoteId": null,\n' +
//                '          "SourceSystem": null,\n' +
//                '          "SourceSystemIdentifier": null,\n' +
//                '          "StandardFeeAmount": null,\n' +
//                '          "StandardPremiumAmount": null,\n' +
//                '          "StandardTaxAmount": null,\n' +
//                '          "Status": "Initial",\n' +
//                '          "Substatus": "Draft",\n' +
//                '          "TaxesSurcharges": null,\n' +
//                '          "TermFeeAmount": null,\n' +
//                '          "TermPremiumAmount": null,\n' +
//                '          "TermTaxAmount": null,\n' +
//                '          "TotalCommissionAmount": null,\n' +
//                '          "TotalSumInsured": null,\n' +
//                '          "TotalTermFeeAmount": null,\n' +
//                '          "TotalTermPremiumAmount": null,\n' +
//                '          "TotalTermTaxAmount": null,\n' +
//                '          "UnderwritingEntityId": null,\n' +
//                '          "UniversalPolicyNumber": "123456",\n' +
//                '          "WritingCarrierAccountId": null,\n' +
                '          "Name": "123456"\n' +
                '        }\n' +
                '      \n' +
                '\n' +
                '}\n' +
                '';
        return jsonStr;

    }

    private static String cognisurefieldmap(){

        String jsonStr = '{\n' +
                '    "Account":{\n' +
                '        "Name": "Namedinsured_Fullname"\n' +
                '    },\n' +
                '    "Claim": {\n' +
                '        "Name": "Claim_Nbr",\n' +
                '        "ActualAmount": "Total_Incurred",\n' +
                '        "ApprovedAmount": "Net_Total_Incurred",\n' +
                '        "assessmentDate": "Valuation_Date",\n' +
                '        "lossdate": "Loss_Date",\n' +
                '        "IsDrivable": null,\n' +
                '        "Status": "Claim_Status",\n' +
                '        "Cause_of_Loss__c": "Cause_Of_Loss",\n' +
                '\t\t"Summary": "Loss_Desc",\n' +
                '\t\t"ClaimType": "Claim_Type",\n' +
                '\t\t"EstimatedAmount": "Net_Reserved",\n' +
                '\t\t"FinalizedDate": "Closed_Date",\n' +
                '\t\t"IncidentSiteCity": "City",\n' +
                '\t\t"IncidentSiteState": "State",\n' +
                '\t\t"ReportDate": "Reported_Date"\n' +
                '    },\n' +
                '    "CustomerProperty": {\n' +
                '        "Premises_Number__c": "Commercialstructure_Location_Produceridentifier",\n' +
                '        "Building_Number__c": "Commercialstructure_Building_Produceridentifier",\n' +
                '        "Address": "Commercialstructure_Physicaladdress_Lineone",\n' +
                '\t\t"State": "Commercialstructure_Physicaladdress_Stateorprovincecode",\n' +
                '        "City": "Commercialstructure_Physicaladdress_Cityname",\n' +
                '\t\t"PostalCode": "Commercialstructure_Physicaladdress_Postalcode",\n' +
                '        "BuiltUpArea": "Construction_Buildingarea",\n' +
                '        "ConstructionClass": "Construction_Constructioncode",\n' +
                '        "FloorCount": "Construction_Storeycount",\n' +
                '        "YearBuilt": "Commercialstructure_Builtyear",\n' +
                '        "Occupancy__c": "Buildingoccupancy_Otheroccupanciesdescription",\n' +
                '        "Protection_Class__c": "Buildingfireprotection_Protectionclasscode",\n' +
                '        "Wiring_Year__c": "Buildingimprovement_Wiringyear",\n' +
                '        "Plumbing_Year__c": "Buildingimprovement_Plumbingyear",\n' +
                '        "Roofing_Year__c": "Buildingimprovement_Roofingyear",\n' +
                '        "Heating_Year__c": "Buildingimprovement_Heatingyear",\n' +
                '        "Vin": "Vehicle_Vinidentifier",\n' +
                '        "Make": "Vehicle_Manufacturersname",\n' +
                '        "MakeYear": "Vehicle_Modelyear",\n' +
                '        "GrossVehicleWeight": "Vehicle_Grossvehicleweight",\n' +
                '        "ModelName": "Vehicle_Modelname"\n' +
                '\t},\n' +
                '    "WorkerCompCoverageClass": {\n' +
                '        "InsurancePolicyId": "Policy_Policynumberidentifier",\n' +
                '        "Premium": "Workerscompensation_Rateclass_Estimatedmanualpremiumamount",\n' +
                '\t\t"Rating_State__c": "Workerscompensation_Ratestate_Stateorprovincename",\n' +
                '\t\t"WorkerLocationId": "Workerscompensation_Rateclass_Locationproduceridentifier",\n' +
                '\t\t"WorkerClass": "Workerscompensation_Rateclass_Classificationcode",\n' +
                '\t\t"TotalExposure": "Workerscompensation_Rateclass_Remunerationamount",\n' +
                '\t\t"Rateclass_Rate__c": "Workerscompensation_Rateclass_Rate",\n' +
                '\t\t"Name": "Workerscompensation_Rateclass_Descriptioncode"\t\n' +
                '    },\n' +
                '    "CoverageType": {\n' +
                '        "DeductibleAmount": "Commercialproperty_Premises_Deductibleamount",\n' +
                '        "Description": "Commercialproperty_Premises_Subjectofinsurancecode",\n' +
                '        "EffectiveDate": "Policy_Effectivedate",\n' +
                '        "ExpirationDate": "Policy_Expirydate",\n' +
                '        "LimitAmount": "Commercialproperty_Premises_Limitamount"\n' +
                '    },\n' +
                '    "InsurancePolicy": {\n' +
                '        "Name": "123456"\n' +
                '    }\n' +
                '}';
        return jsonStr;
    }

    private static String cognisure_Sobject_Mapping(){

        String jsonStr = '{\n' +
                '    "Account": "Account_Level_Info",\n' +
                '    "Claim": "Claim_Info",\n' +
                '    "CustomerProperty": "Property_Policy_Info_Premises_Information",\n' +
                '    "WorkerCompCoverageClass": "WC_Policy_Info_State_Rating_Worksheet",\n' +
                '    "CoverageType": "Property_Policy_Info_Premises_Information",\n' +
                '    "InsurancePolicy": "Property_Policy_Info_Premises_Information"\n' +
                '}';
        return jsonStr;


    }

    private static String cognisure_Sobject_External_Ids(){

        String jsonStr = '{\n' +
                '    "Claim" : "Name",\n' +
                '    "CustomerProperty" : "",\n' +
                '    "WorkerCompCoverageClass" : "",\n' +
                '    "CoverageType" : "",\n' +
                '    "InsurancePolicy" : "",\n' +
                '    "Account" : ""\n' +
                '}';
        return jsonStr;


    }

    public static StaticResource get_cognisure_sffield_defaults_sr(){
        StaticResource resource = new StaticResource();
        resource.Name = 'cognisure_sffield_defaults.json';
        resource.ContentType = 'application/json';
        resource.Body = Blob.valueOf(cognisure_sffield_defaults());
        return resource;
    }

    public static StaticResource get_cognisurefieldmap_sr(){
        StaticResource resource = new StaticResource();
        resource.Name = 'cognisure_sffield_defaults.json';
        resource.ContentType = 'application/json';
        resource.Body = Blob.valueOf(cognisurefieldmap());
        return resource;
    }

    public static StaticResource get_cognisure_Sobject_Mapping_sr(){
        StaticResource resource = new StaticResource();
        resource.Name = 'cognisure_sffield_defaults.json';
        resource.ContentType = 'application/json';
        resource.Body = Blob.valueOf(cognisure_Sobject_Mapping());
        return resource;
    }

    public static StaticResource get_cognisure_Sobject_External_Ids_sr(){
        StaticResource resource = new StaticResource();
        resource.Name = 'cognisure_sffield_defaults.json';
        resource.ContentType = 'application/json';
        resource.Body = Blob.valueOf(cognisure_Sobject_External_Ids());
        return resource;
    }

    public static void getStaticResourceData() {

        get_cognisure_sffield_defaults_sr();
        get_cognisurefieldmap_sr();
        get_cognisure_Sobject_Mapping_sr();
        get_cognisure_Sobject_External_Ids_sr();
    }


    }