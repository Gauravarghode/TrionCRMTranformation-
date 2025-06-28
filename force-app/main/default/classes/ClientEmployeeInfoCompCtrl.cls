public class ClientEmployeeInfoCompCtrl {

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
        for(Proposal__c pro : [SELECT Id, Client__c,Opportunity__c, Opportunity__r.StageName FROM Proposal__c WHERE Id=:recordId]){
            oProposal = pro;
        }
        return oProposal;
    }
    
    @AuraEnabled
    public static List<SUTA_Quote__c> getProposalSUTAQuoteRecords(String proposalId){
        List<SUTA_Quote__c> lstQuotes = new List<SUTA_Quote__c>();
        for(SUTA_Quote__c oQuote : [SELECT Id, Proposal__c,State_Name__c, of_Employees__c,Gross_Wages__c
                                    FROM SUTA_Quote__c
                                   WHERE Proposal__c =:proposalId
                                   ORDER BY State_Name__c ASC]){
            lstQuotes.add(oQuote);
        }
        return lstQuotes; 
    }

    @AuraEnabled
    public static map<String,String> getStates(){
        map<String,String> mapStateOptions = new map<String,String>();
        for(State__c oState : [SELECT Id, Name FROM State__c Order BY Name]){
            mapStateOptions.put(oState.Id,oState.Name);
        }
        return mapStateOptions;
    }
    
	@AuraEnabled
    public static void deleteSUTAQuoteRecords(List<SUTA_Quote__c> lstSUTAQuote){
        try{
            delete lstSUTAQuote;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }

	@AuraEnabled
    public static void submitClinetInfo(String opportunityId, 
                                        String proposalId, 
                                        String stateId, 
                                        Decimal numberOfEmployees, 
                                        Decimal grossWages){
        try{
            upadateOpportunity(opportunityId);
            createAndUpdateQuoteRecords(proposalId,stateId, numberOfEmployees,grossWages);
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }

    public static void upadateOpportunity(String oppId){
        Opportunity opp = new Opportunity();
        for(Opportunity p : [SELECT Id, State_Comp_Info_Received__c FROM Opportunity WHERE Id=:oppId]){
            p.State_Comp_Info_Received__c = true;
            opp = p;
        }
        if(opp != null && opp.Id != null){
            update opp;
        }
    }    
    
    public static void createAndUpdateQuoteRecords(String proposalId, String stateId, Decimal numberOfEmployees, Decimal grossWages){
        List<SUTA_Quote__c> lstQuotes = new List<SUTA_Quote__c>();
        for(SUTA_Quote__c oQuote : [SELECT Id, of_Employees__c,Gross_Wages__c
                                    FROM SUTA_Quote__c
                                   WHERE Proposal__c =:proposalId AND State__c =:stateId]){
           oQuote.of_Employees__c = numberOfEmployees;
           oQuote.Gross_Wages__c = grossWages;
           lstQuotes.add(oQuote);
        }
        
        if(lstQuotes.size()>0){
            update lstQuotes;
        }else{
            SUTA_Quote__c oQuote = new SUTA_Quote__c();
            oQuote.Proposal__c = proposalId;
            oQuote.State__c = stateId;
            oQuote.of_Employees__c = numberOfEmployees;
           	oQuote.Gross_Wages__c = grossWages;
            insert oQuote;
        }
    }
}