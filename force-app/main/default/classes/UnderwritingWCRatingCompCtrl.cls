public class UnderwritingWCRatingCompCtrl {

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
    public static Proposal__c getProposalDetails(String recordId){
        Proposal__c oProposal = new Proposal__c();
        for(Proposal__c proposal : [SELECT Id,Carrier_Cost__c,
                                    Manual_Premium__c, Selected_Losses__c, Total_WC_Gross_Wages__c,
                                    Total_WC_Number_of_Employees__c
                                    FROM Proposal__c WHERE Id=:recordId]){
            oProposal = proposal; 
        }
        return oProposal;
    }
    
    @AuraEnabled
    public static List<WC_Rate__c> getWCRateRecords(String proposalId){
        List<WC_Rate__c> lstWCRate = new List<WC_Rate__c>();
        for(WC_Rate__c oWCRate : [SELECT Id,SUTA_Quote__r.State__r.State_Code__c,Description__c,of_Employees__c,
                                  Gross_Wages__c,Carrier_Rate__c,Client_Exp_Mod__c, Current_Rate__c, Exp_Mod_Rate__c, 
                                  Debit_Discount__c, Exp_Mod_Premium__c, Total_Employees__c,
                                  Part_Time_Employees__c,SUTA_Quote__r.State__r.Id, Estimated_Annual_Manual_Premium__c,
                                  State_Comp_Code__c, SUTA_Quote__r.State__c, SUTA_Quote__r.State__r.Name,
                                  Client_Location__c, Client_Location__r.Loc__c, Underwriting_Rate__c, Underwriting_Premium__c
                                  FROM WC_Rate__c 
                                  WHERE Proposal__c =:proposalId
                                 ORDER BY SUTA_Quote__r.State__r.State_Code__c ASC]){
            lstWCRate.add(oWCRate);
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
    public static void updateWCRateStateCompCode(String wcRateId, String stateCompCode){
        try{
            WC_Rate__c oWC_Rate = new WC_Rate__c(Id=wcRateId, State_Comp_Code__c=stateCompCode);
            update oWC_Rate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getWCCarrier(){
        Map<String, String> mapCarrier = new Map<String, String>();
        for(Account acc : [SELECT Id, Name FROM Account WHERE Type = 'WC Carrier']){
            mapCarrier.put(acc.Id, acc.Name);
        }
        return mapCarrier;
    }
    
    @AuraEnabled
    public static void updateWCRateCarrier(List<WC_Rate__c> lstWCRate, String carrierId){
        try{
            update lstWCRate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
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
        for(SUTA_Quote__c quote : [SELECT Id,State__c, State_Name__c, of_Employees__c, Gross_Wages__c,Proposal__c,
                                   Total_of_Employees__c,Total_Gross_Wages__c
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
                                   Total_Gross_Wages__c,Total_of_Employees__c,Proposal__c
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
    public static void updateMasterSUTAQuote(String jsonWrapper, List<SUTA_Quote__c> lstSUTAQuote, String carrierId, String policyId, String policyYearId){
        try{
            Set<String> setProposalIds = new Set<String>();
            if(lstSUTAQuote != null && lstSUTAQuote.size()>0 && policyId != null){
                for(SUTA_Quote__c quote : lstSUTAQuote){
                    quote.Policy__c = policyId;
                    setProposalIds.add(quote.Proposal__c);
                }
                update lstSUTAQuote;
            }
            
            List<SUTA_Quote__c> lstMCPSUTAQuote = new List<SUTA_Quote__c>();
            List<MCPStateWrapper> lstMCPStateWrapper = (List<MCPStateWrapper>)JSON.deserialize(jsonWrapper, List<MCPStateWrapper>.Class);
            
            if(lstMCPStateWrapper != null && lstMCPStateWrapper.size()>0){
                for(MCPStateWrapper oWrapper : lstMCPStateWrapper){
                    for(SUTA_Quote__c quote : oWrapper.lstSUTAQuote){
                        if(oWrapper.selectedPolicy != null && oWrapper.selectedPolicy.size()>0){
                            quote.Policy__c = oWrapper.selectedPolicy[0].Id;
                            setProposalIds.add(quote.Proposal__c);
                        }
                        lstMCPSUTAQuote.add(quote);
                    }
                }
            }
            
            List<Proposal__c> lstProposal = new List<Proposal__c>();
            if(setProposalIds.size()>0 && policyYearId != null && policyYearId != ''){
                for(Proposal__c oProposal : [SELECT Id, Policy_Year__c FROM Proposal__c WHERE Id IN:setProposalIds]){
                    oProposal.Policy_Year__c = policyYearId;
                    lstProposal.add(oProposal);
                }
            }

            if(lstProposal.size()>0){
                update lstProposal;
            }
            
            if(lstMCPSUTAQuote.size()>0){
                update lstMCPSUTAQuote;
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateDebitDiscount(Decimal mod, List<WC_Rate__c> lstWCRate){
        try{
            for(WC_Rate__c oRate : lstWCRate){
                oRate.Debit_Discount__c = mod;
            }
            update lstWCRate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getPolicyYears(){
        Map<String, String> mapYears = new Map<String, String>();
        for(Policy_Year__c oYear : [SELECT Id, Name FROM Policy_Year__c WHERE Status__c = 'Active' ORDER BY Name ASC]){
            mapYears.put(oYear.Id, oYear.Name);
        }
        return mapYears;
    }
    
}