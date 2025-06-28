public class PEOClientEmployeeInfoCompCtrl {
    
    @AuraEnabled
    public static boolean isButtonVisibilitySOQLFilter(String visibilitysoqlFilter, String recordId){
        boolean isButtonVisible = false;
        String objName = String.valueOf(Id.valueOf(recordId).getSobjectType());
        if(objName != null && objName != ''){
            String soql = 'SELECT Id FROM '+objName;
            if(visibilitysoqlFilter != null && visibilitysoqlFilter != '' && !visibilitysoqlFilter.toLowerCase().contains('where')){
                soql += ' WHERE ';
            }
            
            if(visibilitysoqlFilter != null && visibilitysoqlFilter != ''){
                soql += ' '+visibilitysoqlFilter;
                soql += ' AND ';
            }else {
                soql += ' WHERE ';
            }
            soql += ' Id=:recordId ';
            for(sObject obj : database.query(soql)){
                isButtonVisible = true;
            }
        }
        return isButtonVisible;
    }
    
    @AuraEnabled
    public static String getObjectName(String recordId){
        return String.valueOf(Id.valueOf(recordId).getSobjectType()).toLowerCase();
    }
    
    @AuraEnabled
    public static Opportunity getOpportunityDetails(String recordId){
        Opportunity opp = new Opportunity();
        for(Opportunity oOpportunity : [SELECT Id, Proposal__c, StageName,Proposal__r.Client__c
                                        FROM Opportunity 
                                        WHERE Id=:recordId]){
            opp = oOpportunity;
        }
        return opp;
    }
    
    @AuraEnabled
    public static Proposal__c getProposalDetails(String recordId){
        Proposal__c oProposal = new Proposal__c();
        for(Proposal__c pro : [SELECT Id, Client__c,Opportunity__c, Opportunity__r.StageName,
                               Opportunity__r.AccountId
                               FROM Proposal__c 
                               WHERE Id=:recordId]){
            oProposal = pro;
        }
        return oProposal;
    }
    
    @AuraEnabled
    public static List<SUTA_QuoteWrapper> getProposalSUTAQuoteRecords(String proposalId){
        List<SUTA_QuoteWrapper> lstSUTA_QuoteWrapper = new List<SUTA_QuoteWrapper>();
        
        List<SUTA_Quote__c> lstQuotes = new List<SUTA_Quote__c>();
        for(SUTA_Quote__c oQuote : [SELECT Id, Proposal__c,State__c, State_Name__c, of_Employees__c,Gross_Wages__c,
                                         Proposal__r.Opportunity__r.AccountId,
                                        Total_of_Employees__c,Total_Gross_Wages__c
                                    FROM SUTA_Quote__c
                                   WHERE Proposal__c =:proposalId
                                   ORDER BY State_Name__c ASC]){
            lstQuotes.add(oQuote);
        }
        
        Set<Id> setClientLocation = new Set<Id>();
        Map<String, List<Client_Location__c>> mapCientLocations = new Map<String, List<Client_Location__c>>();
        for(Client_Location__c oClientLocation : [SELECT Id, Loc__c, Street__c, City__c,County__c,Zip_Code__c,
                                                  SUTA_Quote__c
                                                  FROM Client_Location__c 
                                                  WHERE Proposal__c =:proposalId AND SUTA_Quote__c IN:lstQuotes
                                                 ORDER BY SUTA_Quote__c,Loc__c ASC]){
            setClientLocation.add(oClientLocation.Id);
            if(!mapCientLocations.containsKey(oClientLocation.SUTA_Quote__c)){
               mapCientLocations.put(oClientLocation.SUTA_Quote__c, new List<Client_Location__c>());
            }
            mapCientLocations.get(oClientLocation.SUTA_Quote__c).add(oClientLocation);
        }
        
        Map<String, List<WC_Rate__c>> mapWCRates = new Map<String, List<WC_Rate__c>>();
        for(WC_Rate__c oRate : [SELECT Id, State_Comp_Code__r.WC_Code__r.Code__c, Description__c, Part_Time_Employees__c,
                                of_Employees__c, Gross_Wages__c, Current_Rate__c,Client_Location__c,
                                Estimated_Annual_Manual_Premium__c
                                FROM WC_Rate__c 
                                WHERE Client_Location__c IN:setClientLocation
                                AND Proposal__c =:proposalId 
                                AND SUTA_Quote__c IN:lstQuotes
                               ORDER BY Client_Location__c ASC]){
            if(!mapWCRates.containsKey(oRate.Client_Location__c)){
               mapWCRates.put(oRate.Client_Location__c, new List<WC_Rate__c>());
            }
            mapWCRates.get(oRate.Client_Location__c).add(oRate);
        }
        
        Map<String, List<WC_Rate__c>> mapNoLocationWCRates = new Map<String, List<WC_Rate__c>>();
        for(WC_Rate__c oRate : [SELECT Id, State_Comp_Code__r.WC_Code__r.Code__c, Description__c, Part_Time_Employees__c,
                                of_Employees__c, Gross_Wages__c, Current_Rate__c,Client_Location__c,
                                Estimated_Annual_Manual_Premium__c, SUTA_Quote__c, SUTA_Quote__r.State__r.Name,
                                Client_Location__r.Loc__c
                                FROM WC_Rate__c 
                                WHERE Proposal__c =:proposalId 
                                AND SUTA_Quote__c IN:lstQuotes
                                AND Client_Location__c = null
                               ORDER BY Client_Location__c ASC]){
            if(!mapNoLocationWCRates.containsKey(oRate.SUTA_Quote__c)){
               mapNoLocationWCRates.put(oRate.SUTA_Quote__c, new List<WC_Rate__c>());
            }
            mapNoLocationWCRates.get(oRate.SUTA_Quote__c).add(oRate);
        }
        
        if(lstQuotes.size()>0){
            for(SUTA_Quote__c oQuote :lstQuotes){
                SUTA_QuoteWrapper oQuoteWrapper = new SUTA_QuoteWrapper();
                oQuoteWrapper.oQuote = oQuote;
                oQuoteWrapper.lstRateWrapper = new List<WC_RateWrapper>();
                if(mapNoLocationWCRates.containsKey(oQuote.Id)){
                    for(WC_Rate__c oRate : mapNoLocationWCRates.get(oQuote.Id)){
                        WC_RateWrapper oWrapper = new WC_RateWrapper();
                        oWrapper.oRate = oRate;
                        oQuoteWrapper.lstRateWrapper.add(oWrapper);
                    }
                }
                oQuoteWrapper.lstClientLocationWrapper = new List<ClientLocationWrapper>();
                if(mapCientLocations.containsKey(oQuote.Id)){
                    for(Client_Location__c oClientLocation : mapCientLocations.get(oQuote.Id)){
                        ClientLocationWrapper oClientLocationWrapper = new ClientLocationWrapper();
                        oClientLocationWrapper.oClientLocation = oClientLocation;
                        oClientLocationWrapper.lstWCRates = new List<WC_RateWrapper>();
                        if(mapWCRates.containsKey(oClientLocation.Id)){
                            for(WC_Rate__c oRate : mapWCRates.get(oClientLocation.Id)){
                                WC_RateWrapper oWrapper = new WC_RateWrapper();
                                oWrapper.oRate = oRate;
                                oClientLocationWrapper.lstWCRates.add(oWrapper);
                            }
                        }
                        oQuoteWrapper.lstClientLocationWrapper.add(oClientLocationWrapper);
                    }
                }
                lstSUTA_QuoteWrapper.add(oQuoteWrapper);
            }
        }
        
        
        return lstSUTA_QuoteWrapper; 
    }
    
    @AuraEnabled
    public static List<SUTA_Quote__c> createState(String proposalId, List<SUTA_Quote__c> lstQuoteState){
        try{
            set<String> setStateId = new set<String>();
            for(SUTA_Quote__c oQuote : lstQuoteState){
                setStateId.add(oQuote.State__c);
            }
            List<SUTA_Quote__c> lstQuotesToReturn = new List<SUTA_Quote__c>();
            for(SUTA_Quote__c oQuote : [SELECT Id, State__c FROM SUTA_Quote__c
                                       WHERE Proposal__c =:proposalId AND State__c IN:setStateId
                                       ORDER BY State_Name__c ASC]){
                lstQuotesToReturn.add(oQuote);
            }       
            if(lstQuotesToReturn.size() == 0){
                for(SUTA_Quote__c oQuote : lstQuoteState){
                    SUTA_Quote__c quote = new SUTA_Quote__c();
                    quote.Proposal__c = proposalId;
                    quote.State__c = oQuote.State__c;
                    lstQuotesToReturn.add(quote);
                }
                insert lstQuotesToReturn;
                lstQuotesToReturn = new List<SUTA_Quote__c>();
            }
            return lstQuotesToReturn;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteSUTARecord(String recordId){
        try{
            SUTA_Quote__c oQuote = new SUTA_Quote__c(Id=recordId);
            delete oQuote;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteSUTARecords(String jsonWrapper){
        try{
            List<SUTA_QuoteWrapper> lstWrapper = (List<SUTA_QuoteWrapper>)JSON.deserialize(jsonWrapper, List<SUTA_QuoteWrapper>.class);
            List<SUTA_Quote__c> lstQuote = new List<SUTA_Quote__c>();
            List<WC_Rate__c> lstWCRate = new List<WC_Rate__c>();
            
            for(SUTA_QuoteWrapper oWrapper : lstWrapper){
                if(oWrapper.isSelected){
                    lstQuote.add(oWrapper.oQuote);
                }
                
                if(oWrapper.lstClientLocationWrapper.size()>0){
                    for(ClientLocationWrapper oClientWrapper : oWrapper.lstClientLocationWrapper){
                        if(oClientWrapper.lstWCRates.size()>0){
                            for(WC_RateWrapper oRateWrapper : oClientWrapper.lstWCRates){
                                if(oRateWrapper.isSelected){
                                    lstWCRate.add(oRateWrapper.oRate);
                                }
                            }
                        }
                    }
                }
                
                
            }
            
            if(lstQuote.size()>0){
                delete lstQuote;
            }
            
            if(lstWCRate.size()>0){
                delete lstWCRate;
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createClientLocation(Client_Location__c oClientLocation){
        try{
            insert oClientLocation;
            return oClientLocation.Id;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteClientLocation(String clientLocationId){
        try{
            Client_Location__c oClientLocation = new Client_Location__c(Id=clientLocationId);
            delete oClientLocation;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createWCRate(WC_Rate__c oWCRate){
        try{
            boolean isDuplicate = false;
            if(oWCRate.Id != null){
                for(WC_Rate__c oRate : [SELECT Id FROM WC_Rate__c 
                                        WHERE Id!=:oWCRate.Id 
                                            AND State_Comp_Code__c =:oWCRate.State_Comp_Code__c
                                            AND Client_Location__c =:oWCRate.Client_Location__c
                                            AND Proposal__c =: oWCRate.Proposal__c]){
                    isDuplicate = true;
                }
            }else{
                for(WC_Rate__c oRate : [SELECT Id FROM WC_Rate__c 
                                        WHERE State_Comp_Code__c =:oWCRate.State_Comp_Code__c
                                            AND Client_Location__c =:oWCRate.Client_Location__c
                                            AND Proposal__c =: oWCRate.Proposal__c]){
                    isDuplicate = true;
                }
            }
            
            if(!isDuplicate){
                /*if(oWCRate.State_Comp_Code__c != null){
                    for(State_Comp_Code__c oCode : [SELECT Id, WC_Code__c FROM State_Comp_Code__c WHERE Id=:oWCRate.State_Comp_Code__c]){
                        oWCRate.Comp_Code__c = oCode.WC_Code__c;
                    }
                }
                */   
                upsert oWCRate;             
            }else{
                throw new AuraException('Duplicate Record Found!');
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static WC_Rate__c getWCRate(String wcRateId){
        WC_Rate__c oRate = new WC_Rate__c();
        for(WC_Rate__c rate : [SELECT Id, Name, State_Comp_Code__c,Part_Time_Employees__c,
                               of_Employees__c,Gross_Wages__c,Current_Rate__c,
                               SUTA_Quote__r.State__c, SUTA_Quote__r.State__r.Name,State_Comp_Code__r.State__r.Name, State_Comp_Code__r.State__c,
                               Client_Location__c
                               FROM WC_Rate__c WHERE Id=:wcRateId]){
            oRate = rate;
        }
        return oRate;
    }
    
    /*@AuraEnabled
    public static Integer getNewClientLocation(String proposalId){
        Integer loc = 1;
        for(Client_Location__c clientLocation : [SELECT Id, Loc__c FROM Client_Location__c 
                                                 WHERE Proposal__c=:proposalId 
                                                 AND Loc__c != null ORDER BY Loc__c DESC limit 1]){
            loc += Integer.valueOf(clientLocation.Loc__c);
        }
        return loc;
    }*/
    
    @AuraEnabled
    public static Map<String, String> getStates(){
        Map<String, String> mapState = new Map<String, String>();
        for(State__c oState : [SELECT Id, Name FROM State__c ORDER BY Name ASC]){
            mapState.put(oState.Id, oState.Name);            
        }
        return mapState;
    }
    
    @AuraEnabled
    public static Map<String, String> getClientLocationPicklistValues(String proposalId, String stateId){
        Map<String, String> mapClientLocationPicklistValues = new Map<String, String>();
        for(Client_Location__c oClientLocation : [Select Id, Name, Location__c FROM Client_Location__c 
                                                  WHERE Proposal__c=:proposalId 
                                                  AND SUTA_Quote__r.State__c =:stateId]){
            String location = null;
            if(oClientLocation.Location__c != null){
                location = oClientLocation.Location__c.replaceAll('<br>', ' ');        
            }
            mapClientLocationPicklistValues.put(oClientLocation.Id, oClientLocation.Name+' - '+(location!=null?location:''));
        }
        return mapClientLocationPicklistValues;
    }
    
    @AuraEnabled
    public static Client_Location__c getNewClientLocation(String proposalId, String stateId, String accId){
        try{
            Id sutaQuoteId;
            Integer loc = 1;
            Client_Location__c oClientLocation = new Client_Location__c();
            
            for(SUTA_Quote__c oQuote : [SELECT Id FROM SUTA_Quote__c 
                                        WHERE State__c=:stateId AND Proposal__c=:proposalId limit 1]){
                sutaQuoteId = oQuote.Id;
            }
            
            if(sutaQuoteId != null){
                for(Client_Location__c clientLocation : [SELECT Id, Loc__c FROM Client_Location__c 
                                                         WHERE Client__c=:accId AND Loc__c != null 
                                                         ORDER BY Loc__c DESC limit 1]){
                    loc += Integer.valueOf(clientLocation.Loc__c);
                }
            }else{
                SUTA_Quote__c oQuote = new SUTA_Quote__c();
                oQuote.Proposal__c = proposalId;
                oQuote.State__c = stateId;
                insert oQuote;
                sutaQuoteId = oQuote.Id;
            }
            
            oClientLocation.Proposal__c = proposalId;
            oClientLocation.SUTA_Quote__c = sutaQuoteId;
            oClientLocation.Client__c = accId;
            oClientLocation.Loc__c = loc;
            
            return oClientLocation;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0)+dmlex.getStackTraceString());
        }catch(Exception ex){
            throw new AuraException(ex.getMessage()+ex.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void createWCCode(String proposalId, String stateId, WC_Rate__c oRate){
        try{
            Id sutaQuoteId;
            for(SUTA_Quote__c oQuote : [SELECT Id FROM SUTA_Quote__c 
                                        WHERE State__c=:stateId 
                                            AND Proposal__c=:proposalId limit 1]){
                sutaQuoteId = oQuote.Id;
            }
            
            if(sutaQuoteId == null){
                SUTA_Quote__c oQuote = new SUTA_Quote__c();
                oQuote.Proposal__c = proposalId;
                oQuote.State__c = stateId;
                insert oQuote;
                sutaQuoteId = oQuote.Id;
            }
            oRate.SUTA_Quote__c = sutaQuoteId; 
            oRate.Proposal__c = proposalId;
            insert oRate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0)+dmlex.getStackTraceString());
        }catch(Exception ex){
            throw new AuraException(ex.getMessage()+ex.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static Client_Location__c getClientLocation(String clientLocationId){
        Client_Location__c oClientLocation = new Client_Location__c();
        for(Client_Location__c clientLocation: [SELECT Id,Loc__c,State__c FROM Client_Location__c WHERE Id=:clientLocationId]){
            oClientLocation = clientLocation;
        }
        return oClientLocation;
    }
    
    @AuraEnabled
    public static void deleteWCRate(String wcRateId){
        try{
            WC_Rate__c oRate = new WC_Rate__c(Id=wcRateId);
            delete oRate;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0)+dmlex.getStackTraceString());
        }catch(Exception ex){
            throw new AuraException(ex.getMessage()+ex.getStackTraceString());
        }
    }
    
}