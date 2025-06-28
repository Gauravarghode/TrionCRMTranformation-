public class SalesOfficeCompCtrl {

    @AuraEnabled
    public static boolean isButtonVisibilitySOQLFilter(String visibilitysoqlFilter, String recordId){
        boolean isButtonVisible = false;
        String objName = String.valueOf(Id.valueOf(recordId).getSobjectType());
        if(objName != null && objName != ''){
            String soql = 'SELECT Id FROM '+objName;
            if(!visibilitysoqlFilter.toLowerCase().contains('where')){
                soql += ' WHERE ';
            }
            soql += ' '+visibilitysoqlFilter;
            soql += ' AND Id=:recordId ';
            for(sObject obj : database.query(soql)){
                isButtonVisible = true;
            }
        }
        return isButtonVisible;
    }
    @AuraEnabled
    public static Map<String, String> getPicklistValues(String objectName, String fieldName){
        Map<String, String> mapPicklistValues = new Map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            mapPicklistValues.put(pickListVal.getValue(), pickListVal.getLabel());
        }    
        return mapPicklistValues;
    }
    
    @AuraEnabled
    public static List<WC_Rate__c> getWCRateRecords(String proposalId){
        List<WC_Rate__c> lstWCRate = new List<WC_Rate__c>();
        for(WC_Rate__c oRate : [SELECT Id,SUTA_Quote__r.State__r.State_Code__c,State_Comp_Code__r.WC_Code__r.Code__c,Description__c,SUTA_Quote__r.Policy__r.Carrier__r.Name,Total_Employees__c,
                                WC_Bill_Rate__c,Total_Bill_Rate__c,Total_bill_Rate_After_UI_Wage_Limit__c, 
                                Name,SUTA_Quote__c,Sales_Premium__c,Bill_Premium__c,Gross_Wages__c,Manual_Comp_Description__c,
                                Carrier_Rate__c,Assessment_Fee__c,Mod_Calculator__c,of_Employees__c, State_Comp_Code__c,
                                Trion_Adjusted_Bill_Rate__c, Effective_Rate__c, SUTA_Quote__r.State__c, Policy__r.Name,
                                Client_Location__r.Location__c, SUTA_Quote__r.State__r.Name, Client_Location__r.Loc__c,
                                Client_Location__c, SUTA_Quote__r.State__r.Id
                                FROM WC_Rate__c 
                                WHERE Proposal__c =:proposalId
                               ORDER BY SUTA_Quote__r.State__r.State_Code__c ASC]){
            lstWCRate.add(oRate);
        }
        return lstWCRate;
    }
    
    @AuraEnabled
    public static void deleteWCRate(String wcRateId){
        try{
            WC_Rate__c oWC_Rate = new WC_Rate__c(Id=wcRateId);
            delete oWC_Rate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void calculateRates(List<WC_Rate__c> lstWCRate, String selectedCalculateWCRateby, Decimal modifier){
        try{
            for(WC_Rate__c oRate : lstWCRate){
                oRate.Calculate_WC_Rate_by__c = selectedCalculateWCRateby;
                if(selectedCalculateWCRateby == 'Modified WC Rate'){
                    oRate.Modifier__c = modifier;
                }else if(selectedCalculateWCRateby == 'Trion Adjusted WC Bill Rate'){
                    oRate.Trion_Adjusted_Bill_Rate__c = modifier;
                }else if(selectedCalculateWCRateby == 'WC Charge Rate'){
                    oRate.Effective_Rate__c = modifier;
                }
            }
            update lstWCRate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getActiveCarrier(){
        Map<String, String> mapCarrier = new Map<String, String>();
        for(Account oAccount : [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Carrier' AND Status__c = 'Active']){
            mapCarrier.put(oAccount.Id, oAccount.Name);
        }
        return mapCarrier;
    }
    
    @AuraEnabled
    public static List<Policy__c> getPolicies(String carrierId, String proposalId){
        List<Policy__c> lstPolicy = new List<Policy__c>();
        
        boolean isMasterStateFound = false;
        for(SUTA_Quote__c quote : [SELECt Id, Policy__c 
                                   FROM SUTA_Quote__c
                                   WHERE Proposal__c=:proposalId AND Policy_Type__c= 'Master'
                                    ORDER BY State_Name__c limit 1]){
            isMasterStateFound = true;
        }
        
        if(isMasterStateFound){
            for(Policy__c policy : [SELECT Id,Name,Effective_Date__c, Type__c
                                    FROM Policy__c 
                                    WHERE Status__c = 'Active' AND Type__c = 'Master'
                                   ORDER BY Effective_Date__c ASC]){
                lstPolicy.add(policy);            
            }
        }
        
        return lstPolicy;
    }
    
    @AuraEnabled
    public static List<SUTA_Quote__c> getMasterSutaQuote(String proposalId){
        List<SUTA_Quote__c> lstSUTA_Quote = new List<SUTA_Quote__c>();
        for(SUTA_Quote__c quote : [SELECT Id,State__c, State_Name__c, of_Employees__c, Gross_Wages__c 
                                   FROM SUTA_Quote__c 
                                   WHERE Proposal__c=:proposalId 
                                   AND State_Classification__c IN ('Master','Monopolistic')
                                  ORDER BY State_Name__c]){
            lstSUTA_Quote.add(quote);
        }
        return lstSUTA_Quote;
    }
    
    @AuraEnabled
    public static List<MCPStateWrapper> getMCPStateWrapper(String proposalId, String carrierId){
        List<MCPStateWrapper> lstMCPStateWrapper = new List<MCPStateWrapper>();
        
        Map<String, List<SUTA_Quote__c>> mapSUTAQuote = new Map<String, List<SUTA_Quote__c>>();
        for(SUTA_Quote__c quote : [SELECT Id,State__c, State_Name__c, of_Employees__c, Gross_Wages__c,Policy__c,
                                   Total_Gross_Wages__c,Total_of_Employees__c
                                   FROM SUTA_Quote__c 
                                   WHERE Proposal__c=:proposalId 
                                   AND Policy_Type__c Like 'MCP%'
                                  ORDER BY State_Name__c]){
           if(!mapSUTAQuote.containsKey(quote.State__c)){
               mapSUTAQuote.put(quote.State__c, new List<SUTA_Quote__c>()); 
           } 
           mapSUTAQuote.get(quote.State__c).add(quote); 
        }
        
        Map<String, List<Policy__c>> mapPolicy = new Map<String, List<Policy__c>>();
        for(Policy__c policy : [SELECT Id,Name,Effective_Date__c, Type__c,State__c
                                FROM Policy__c 
                                WHERE State__c IN:mapSUTAQuote.keyset()
                                AND Status__c = 'Active' 
                                AND Type__c = 'MCP'
                                ORDER BY State__c,Effective_Date__c ASC]){
           if(!mapPolicy.containsKey(policy.State__c)){
               mapPolicy.put(policy.State__c, new List<Policy__c>());
           } 
           mapPolicy.get(policy.State__c).add(policy);          
        }
        
        if(!mapPolicy.isEmpty()){
            for(String stateId : mapPolicy.keyset()){
                lstMCPStateWrapper.add(new MCPStateWrapper(mapPolicy.get(stateId), (mapSUTAQuote.containsKey(stateId)?mapSUTAQuote.get(stateId):new List<SUTA_Quote__c>())));
            }
        }
        
        return lstMCPStateWrapper;
    }
    
    @AuraEnabled
    public static void updateMasterSUTAQuote(String jsonWrapper, List<SUTA_Quote__c> lstSUTAQuote, String carrierId, String policyId){
        try{
            
            if(lstSUTAQuote != null && lstSUTAQuote.size()>0 && policyId != null){
                for(SUTA_Quote__c quote : lstSUTAQuote){
                    quote.Policy__c = policyId;
                }
                WCRateTriggerHandler.runOnce = true;
                update lstSUTAQuote;
            }
            
            List<SUTA_Quote__c> lstMCPSUTAQuote = new List<SUTA_Quote__c>();
            List<MCPStateWrapper> lstMCPStateWrapper = (List<MCPStateWrapper>)JSON.deserialize(jsonWrapper, List<MCPStateWrapper>.Class);
            
            if(lstMCPStateWrapper != null && lstMCPStateWrapper.size()>0){
                for(MCPStateWrapper oWrapper : lstMCPStateWrapper){
                    for(SUTA_Quote__c quote : oWrapper.lstSUTAQuote){
                        if(oWrapper.selectedPolicy != null && oWrapper.selectedPolicy.size()>0){
                            quote.Policy__c = oWrapper.selectedPolicy[0].Id;
                        }
                        lstMCPSUTAQuote.add(quote);
                    }
                }
            }
            
            if(lstMCPSUTAQuote.size()>0){
                WCRateTriggerHandler.runOnce = true;
                update lstMCPSUTAQuote;
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }

    
    @AuraEnabled
    public static List<WC_Rate__c> updateQuoteAndWCRateRecords(String proposalId, String carrierId, String policyId, String type){
        try{
            List<WC_Rate__c> lstWCRate = new List<WC_Rate__c>();
            
            String sSOQL = 'SELECt Id, Policy__c FROM SUTA_Quote__c';
            sSOQL += ' WHERE Proposal__c=:proposalId';
            if(type == 'MCP'){
                sSOQL += ' AND Policy_Type__c Like \''+type+'%\' '; 
            }else{
                sSOQL += ' AND Policy_Type__c=:type';
            }
            
            system.debug('***sSOQL***'+sSOQL);
            List<SUTA_Quote__c> lstSUTAQuote = new List<SUTA_Quote__c>();
            for(SUTA_Quote__c quote : database.query(sSOQL)){
                quote.Policy__c = policyId;
                lstSUTAQuote.add(quote);
            }
            
            if(lstSUTAQuote.size()>0){
                update lstSUTAQuote;
            }
            
            
            String sRateSOQL = 'SELECT Id,SUTA_Quote__r.State__r.State_Code__c,State_Comp_Code__r.WC_Code__r.Code__c,Description__c,SUTA_Quote__r.Policy__r.Carrier__r.Name,';
            sRateSOQL += ' WC_Bill_Rate__c,Total_Bill_Rate__c,Total_bill_Rate_After_UI_Wage_Limit__c,';
            sRateSOQL += ' Name,SUTA_Quote__c,Sales_Premium__c,Gross_Wages__c,Manual_Comp_Description__c,';
            sRateSOQL += ' Carrier_Rate__c,Assessment_Fee__c,Mod_Calculator__c,of_Employees__c'; 
            sRateSOQL += ' FROM WC_Rate__c WHERE Proposal__c =:proposalId';
            
            if(type == 'MCP'){
                sRateSOQL += ' AND SUTA_Quote__r.State__r.State_Classification__c Like \''+type+'%\' '; 
            }else{
                Set<String> setClassification = new Set<String>{'Master','Monopolistic'};
                sRateSOQL += ' AND SUTA_Quote__r.State__r.State_Classification__c IN: setClassification';
            }
            
            sRateSOQL += ' ORDER BY SUTA_Quote__r.State__r.State_Code__c ASC';
            
            system.debug('***sRateSOQL***'+sRateSOQL);
            for(WC_Rate__c oRate : database.query(sRateSOQL)){
                lstWCRate.add(oRate);
            }
            
            return lstWCRate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<WC_Rate__c> updateWCRates(List<WC_Rate__c> lstWCRate, String proposalId, String carrierId, String policyId, String type){
        try{
            for(WC_Rate__c oRate : lstWCRate){
                oRate.Policy__c = policyId;
            }
            update lstWCRate;
            
            List<WC_Rate__c> lstNewWCRate = new List<WC_Rate__c>();
            String sRateSOQL = 'SELECT Id,SUTA_Quote__r.State__r.State_Code__c,State_Comp_Code__r.WC_Code__r.Code__c,Description__c,SUTA_Quote__r.Policy__r.Carrier__r.Name,';
            sRateSOQL += ' WC_Bill_Rate__c,Total_Bill_Rate__c,Total_bill_Rate_After_UI_Wage_Limit__c,';
            sRateSOQL += ' Name,SUTA_Quote__c,Sales_Premium__c,Gross_Wages__c,Manual_Comp_Description__c,';
            sRateSOQL += ' Carrier_Rate__c,Assessment_Fee__c,Mod_Calculator__c,of_Employees__c'; 
            sRateSOQL += ' FROM WC_Rate__c WHERE Proposal__c =:proposalId';
            
            if(type == 'MCP'){
                sRateSOQL += ' AND SUTA_Quote__r.State__r.State_Classification__c  Like \''+type+'%\' '; 
            }else{
                Set<String> setClassification = new Set<String>{'Master','Monopolistic'};
                sRateSOQL += ' AND SUTA_Quote__r.State__r.State_Classification__c IN: setClassification';
            }
            
            sRateSOQL += ' AND Id NOT IN: lstWCRate';
            
            sRateSOQL += ' ORDER BY SUTA_Quote__r.State__r.State_Code__c ASC';
            
            system.debug('***sRateSOQL***171***'+sRateSOQL);
            for(WC_Rate__c oRate : database.query(sRateSOQL)){
                lstNewWCRate.add(oRate);
            }
            return lstNewWCRate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getStates(){
        Map<String, String> mapState = new Map<String, String>();
        for(State__c oState : [SELECT Id, Name FROM State__c ORDER BY Name ASC]){
            mapState.put(oState.Id, oState.Name);            
        }
        return mapState;
    }
    
    @AuraEnabled
    public static List<WC_Rate__c> getWCRateWithState(String proposalId, String stateId){
        List<WC_Rate__c> lstWCRate = new List<WC_Rate__c>();
        for(WC_Rate__c oRate : [SELECT Id, SUTA_Quote__r.State__c, Description__c, of_Employees__c, Gross_Wages__c 
                                FROM WC_Rate__c 
                                WHERE Proposal__c=:proposalId AND SUTA_Quote__r.State__c =:stateId
                               ORDER BY Description__c ASC NULLS FIRST]){
            lstWCRate.add(oRate);
        }
        return lstWCRate;
    }
    
    @AuraEnabled
    public static List<WC_Rate__c> createUpdateWCRate(String proposalId, String stateId, String selectedStateCompCode, Decimal numberofEmployees, Decimal grossWages){
        try{
            List<WC_Rate__c> lstWCRate = new List<WC_Rate__c>();
            for(WC_Rate__c oRate : [SELECT Id, of_Employees__c, Gross_Wages__c FROM WC_Rate__c 
                                    WHERE Proposal__c=:proposalId AND SUTA_Quote__r.State__c =:stateId 
                                    AND State_Comp_Code__c =:selectedStateCompCode]){
                                        oRate.of_Employees__c = numberofEmployees;
                                        oRate.Gross_Wages__c = grossWages;
                                    }
            if(lstWCRate.size()>0){
                update lstWCRate;
            }else{
                SUTA_Quote__c oQuote;
                for(SUTA_Quote__c quote : [SELECT Id FROM SUTA_Quote__c WHERE Proposal__c =:proposalId AND State__c =:stateId limit 1]){
                    oQuote = quote;
                }
                
                if(oQuote == null || oQuote.Id == null){
                    oQuote = new SUTA_Quote__c();
                    oQuote.Proposal__c = proposalId;
                    oQuote.State__c = stateId;
                    insert oQuote;
                }
                
                WC_Rate__c oRate = new WC_Rate__c();
                oRate.Proposal__c = proposalId; 
                oRate.SUTA_Quote__c = oQuote.Id;
                oRate.State_Comp_Code__c = selectedStateCompCode;
                oRate.of_Employees__c = numberofEmployees;
                oRate.Gross_Wages__c = grossWages;
                insert oRate;
            }
            return getWCRateWithState(proposalId, stateId);
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
}