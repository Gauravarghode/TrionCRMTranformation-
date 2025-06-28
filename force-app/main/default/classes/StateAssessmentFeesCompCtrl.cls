public class StateAssessmentFeesCompCtrl {

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
    public static List<SUTA_Quote__c> getSUTARecords(String recordId){
        List<SUTA_Quote__c> lstSUTAQuote = new List<SUTA_Quote__c>();
        for(SUTA_Quote__c oQuote : [SELECT Id, State_Name__c, Proposal_State_Assessment_and_Surcharge__c, 
                                    	Display_State_Assessment_Fee_on_Proposal__c,
                                    	State_Assessment_Fee_Surcharge_Included__c
                                    FROM SUTA_Quote__c WHERE Proposal__c =:recordId
                                   AND SUTA__r.State_Assessment_and_Surcharges__c != null
                                   ORDER BY State_Name__c ASC]){
            lstSUTAQuote.add(oQuote);
        }
        
        return lstSUTAQuote;
    }
    
    @AuraEnabled
    public static void updateSUTARecords(List<SUTA_Quote__c> lstSUTAQuotes, boolean isIncluded){
        try{
            for(SUTA_Quote__c quote : lstSUTAQuotes){
                quote.State_Assessment_Fee_Surcharge_Included__c = isIncluded;
            }
            update lstSUTAQuotes;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
}