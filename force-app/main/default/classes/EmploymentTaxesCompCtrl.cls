public class EmploymentTaxesCompCtrl {
    
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
    public static List<SUTA_Quote__c> getProposalSUTAQuoteRecords(String recordId){
        List<SUTA_Quote__c> lstQuotes = new List<SUTA_Quote__c>();
        for(SUTA_Quote__c oQuote : [SELECT Id, State__c, Reporting_Level__c,Entity__c,
                                        State_Name__c, Proposal_State_Assessment_and_Surcharge__c,
                                        SUTA_Cost_Rate__c,SUTA_Bill_Rate__c,Wage_Base__c,Total_of_Employees__c,
                                        Total_Gross_Wages__c,Year__r.Name,Proposal_SUTA_header__c,
                                        Proposal_SUTA__c,State_Assessment_Fee_Surcharge_Included__c,Proposal__c,
                                        SUTA__c,SUTA__r.Name, Proposal__r.Year__c,Year__c, Name
                                    FROM SUTA_Quote__c
                                   WHERE Proposal__c =:recordId
                                   ORDER BY State_Name__c ASC]){
            lstQuotes.add(oQuote);
        }
        return lstQuotes;
    }
    
    @AuraEnabled
    public static Proposal__c getFederaTaxData(String recordId){
        Proposal__c oProposal = new Proposal__c();
        for(Proposal__c pp : [SELECT Id,FICA__c,FUTA__c,Medicare__c, Year__c 
                              FROM Proposal__c 
                              WHERE Id=:recordId]){
            oProposal = pp;
        }
        return oProposal;
    }
    
    
    @AuraEnabled
    public static Map<String,String> getYears(){
        Map<String,String> mapYears = new Map<String,String>();
        for(Year__c oYear : [SELECT Id, Name FROM Year__c WHERE Status__c = 'Active']){
            mapYears.put(oYear.Id, oYear.Name);
        }
        return mapYears;
    }
    
    @AuraEnabled
    public static void updateProposalYear(String proposalId, String proposalYear){
        try{
            Proposal__c oProposal = new Proposal__c(Id=proposalId,Year__c=proposalYear);
            update oProposal;
            
            List<SUTA_Quote__c> lstSUTAQuote = getProposalSUTAQuoteRecords(proposalId);
            Set<String> setYearId = new Set<String>();
            Set<String> setStateId = new Set<String>();
            
            if(lstSUTAQuote.size()>0){
                for(SUTA_Quote__c quote : lstSUTAQuote){
                    quote.Year__c = proposalYear;
                }
                
                for(SUTA_Quote__c quote : lstSUTAQuote){
                    if(quote.Proposal__r.Year__c != null){
                        setYearId.add(quote.Proposal__r.Year__c);
                    }
                    if(quote.State__c != null){
                        setStateId.add(quote.State__c);
                    }
                }
                
                Id trionSUTAId;
                Id SUTAId;
                
                Map<String, String> mapSuta = new Map<String,String>();
                
                List<SUTA__c> lstSUTA = new List<SUTA__c>();
                for(SUTA__c suta : [SELECT Id, Entity__c, Year__c, State__c
                                    FROM SUTA__c
                                    WHERE Year__c IN:setYearId 
                                    AND State__c IN: setStateId
                                    AND Status__c = 'Active'
                                    ORDER BY Entity__c DESC]){
                    lstSUTA.add(suta);
                }
                
                if(lstSUTA.size()>0){
                    for(SUTA__c suta :lstSUTA){
                        String key = suta.Year__c+'_'+suta.State__c;
                        if(suta.Entity__c != null && suta.Entity__c == 'Trion 2' && !mapSuta.containsKey(key)){
                            mapSuta.put(key, suta.Id);
                        }
                    }
                    
                    for(SUTA__c suta :lstSUTA){
                        String key = suta.Year__c+'_'+suta.State__c;
                        if(!mapSuta.containsKey(key)){
                            mapSuta.put(key, suta.Id);
                        }
                    }
                }
                
                for(SUTA_Quote__c quote : lstSUTAQuote){
                    String key = quote.Year__c+'_'+quote.State__c;
                    if(mapSuta.containsKey(key)){
                        quote.SUTA__c = mapSuta.get(key);
                    }else{
                        quote.SUTA__c = null;
                    }
                }
                update lstSUTAQuote;
            }
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateSUTAQuoteRecords(List<SUTA_Quote__c> lstQuotes){
        try{
            update lstQuotes;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteSUTAQuoteRecords(String quoteId){
        try{
            SUTA_Quote__c oQuote = new SUTA_Quote__c(Id=quoteId);
            delete oQuote;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static map<String,String> getSUTARecords(String sutaId, String stateId, String yearId){
        map<String,String> mapSUTA = new map<String,String>();
        for(SUTA__c suta : [SELECT Id, Name 
                            FROM SUTA__c 
                            WHERE (Id=:sutaId)
                                OR (State__c=:stateId AND Year__c=:yearId AND State__c !=null) 
                            ORDER BY Name
                            limit 10]){
            mapSUTA.put(suta.Id, suta.Name);
        }
        return mapSUTA;
    }
    
}