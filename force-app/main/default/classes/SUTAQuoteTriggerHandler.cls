public class SUTAQuoteTriggerHandler {
    public static Boolean firstRun = true;
    
    public static void onBeforeInsert(List<SUTA_Quote__c> triggerNew){
		updateQuoteYear(triggerNew, null);
    }
    
    public static void updateQuoteYear(List<SUTA_Quote__c> triggerNew, Map<Id, SUTA_Quote__c> triggerOldMap){
		Map<Id,Id> mapProposalIdWithYearId = new Map<Id,Id>();
        Map<String, SUTA__c> mapSUTA = new Map<String, SUTA__c>();
        Set<String> setProposalYearId = new Set<String>();
        Set<String> setStateId = new Set<String>();
        
        for(SUTA_Quote__c oQuote : triggerNew){
            if(oQuote.Year__c == null){
                mapProposalIdWithYearId.put(oQuote.Proposal__c, null);
            }
        }
        
        if(!mapProposalIdWithYearId.isEmpty()){
            for(Proposal__c oProposal : [SELECT Id, Year__c FROM Proposal__c WHERE Id IN:mapProposalIdWithYearId.keySet() AND Year__c != null]){
                mapProposalIdWithYearId.put(oProposal.Id, oProposal.Year__c);
            }
        }
        
        for(SUTA_Quote__c oQuote : triggerNew){
            if(oQuote.Year__c == null 
               	&& mapProposalIdWithYearId.containsKey(oQuote.Proposal__c) 
               	&& mapProposalIdWithYearId.get(oQuote.Proposal__c) != null){
                oQuote.Year__c = mapProposalIdWithYearId.get(oQuote.Proposal__c);
            }
            
            if(oQuote.State__c != null){
                setStateId.add(oQuote.State__c);    
            }
            
            if(oQuote.Year__c != null){
                setProposalYearId.add(oQuote.Year__c);    
            }
            
        }
        
        if(setProposalYearId.size() > 0 && setStateId.size() > 0){
            for(SUTA__c oSUTA : [SELECT Id, Entity__c, State__c,Year__c 
                                 FROM SUTA__c 
                                 WHERE State__c IN: setStateId AND Year__c IN: setProposalYearId]){
                String key = oSUTA.State__c+'_'+oSUTA.Year__c+'_'+((oSUTA.Entity__c!=null && oSUTA.Entity__c == 'Trion 2')?'Trion2':'Trion');
                if(!mapSUTA.containsKey(key)){
                    mapSUTA.put(key, oSUTA);
                }
            }
        }
        
        for(SUTA_Quote__c oQuote : triggerNew){
            if(oQuote.State__c != null && oQuote.Year__c != null){
                if(mapSUTA.containsKey(oQuote.State__c+'_'+oQuote.Year__c+'_Trion2')){
                    oQuote.SUTA__c = mapSUTA.get(oQuote.State__c+'_'+oQuote.Year__c+'_Trion2').Id;
                }else if(mapSUTA.containsKey(oQuote.State__c+'_'+oQuote.Year__c+'_Trion')){
                    oQuote.SUTA__c = mapSUTA.get(oQuote.State__c+'_'+oQuote.Year__c+'_Trion').Id;
                }
            }
        }
    }
    
    
    
    public static void onAfterInsert(List<SUTA_Quote__c> newList, Map<Id, SUTA_Quote__c> oldMap){
        HandleWCRateUpdate(newList, oldMap);
    }
    
    public static void onAfterUpdate(List<SUTA_Quote__c> newList, Map<Id, SUTA_Quote__c> oldMap){
        HandleWCRateUpdate(newList, oldMap); 
    }
    
    public static void HandleWCRateUpdate(List<SUTA_Quote__c> newList, Map<Id, SUTA_Quote__c> oldMap){
        Map<String, String> mapPolicyQuote = new Map<String, String>();
        Map<Id, SUTA_Quote__c> mapQuote = new Map<Id, SUTA_Quote__c>();
         
         
        for(SUTA_Quote__c oQuote: newList){
            if(oQuote.Policy__c != null && (oldMap == null || (oldMap != null && oQuote.Policy__c != oldMap.get(oQuote.Id).Policy__c))){
                mapQuote.put(oQuote.Id, oQuote); 
                mapPolicyQuote.put(oQuote.Id, null);
            }
            if( oldMap == null || (oldMap != null && oQuote.State_Assessment_Fee_Surcharge_Included__c  != oldMap.get(oQuote.Id).State_Assessment_Fee_Surcharge_Included__c  )){
                mapQuote.put(oQuote.Id, oQuote);
            }
        }
        
        if(!mapPolicyQuote.isEmpty()){
            List<SUTA_Quote__c> lstSUTAQuote = new List<SUTA_Quote__c>();
            for(SUTA_Quote__c oQuote : [SELECT Id, Policy__r.Carrier__c FROM SUTA_Quote__c 
                                       WHERE Id IN:mapPolicyQuote.keyset() AND Policy__r.Carrier__c != null]){
                lstSUTAQuote.add(oQuote);
            }
            
            if(lstSUTAQuote.size()>0){
                update lstSUTAQuote;
            }
        }
        
        if(!mapQuote.isEmpty()){

            List<WC_Rate__c> lstWCR = new List<WC_Rate__c>();
            
            for(WC_Rate__c oRate : [Select Id, SUTA_Quote__c From WC_Rate__c Where SUTA_Quote__c IN : mapQuote.keyset()]){
                lstWCR.add(oRate);
            }
            
            if(lstWCR.size() > 0){
                // update child WC_Rate__c
                update lstWCR;
            }
        } 
        
    }
    public static boolean runOnce(){
        if(firstRun){
            firstRun = false;
            return true;
        }else{
            return firstRun;
        }
    }
}