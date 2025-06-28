public class SearchWCCarrierRatesCompCtrl {

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
    public static Map<String, String> getCarrierPicklistValues(){
        Map<String, String> mapCarrierPicklistValues = new Map<String, String>();
        for(Account acc : [SELECT Id, Name FROM Account WHERE RecordType.Name='Carrier' AND Status__c = 'Active']){
            mapCarrierPicklistValues.put(acc.Id, acc.Name);
        }
        return mapCarrierPicklistValues;
    }
    
    @AuraEnabled
    public static Map<String, String> getStatePicklistValues(){
        Map<String, String> mapStatePicklistValues = new Map<String, String>();
        for(State__c oState : [SELECT Id, Name,State_Code__c FROM State__c]){
            mapStatePicklistValues.put(oState.Id, oState.Name+(oState.State_Code__c!=null?' - '+oState.State_Code__c:''));
        }
        return mapStatePicklistValues;
    }
    
    @AuraEnabled
    public static List<Carrier_WC_Rate__c> getCarrierWCRates(String filterJSON){
        List<SearchWCCarrierRatesFilterWrapper> lstFilters = (List<SearchWCCarrierRatesFilterWrapper>)JSON.deserialize(filterJSON, List<SearchWCCarrierRatesFilterWrapper>.class);
        
        List<Carrier_WC_Rate__c> lstCarrierWCRates = new List<Carrier_WC_Rate__c>();
        String sSOQL = 'SELECT Id, WC_Code__c, WC_Code__r.Name, Description__c,';
        sSOQL += ' Carrier__c, Carrier__r.Name, Rate__c, Modifier__c, State_Assessment_Fee__c,';
        sSOQL += ' Trion_Bill_Rate__c, Trion_Bill_Rate_Exc_Assessment_Fees__c, Status__c,';
        sSOQL += ' Effective_Date__c, State__c, State__r.Name, Territory__c, Territory__r.Name';
        sSOQL += ' FROM Carrier_WC_Rate__c';
        
        String sWHERE = null;
        String glueOr = '';
        for(SearchWCCarrierRatesFilterWrapper oWrapper : lstFilters){
            if((oWrapper.selectedCompCode != null && oWrapper.selectedCompCode != '') || (oWrapper.selectedState != null && oWrapper.selectedState != '') || (oWrapper.selectedCarrier != null && oWrapper.selectedCarrier != '') || (oWrapper.selectedStatus != null && oWrapper.selectedStatus != '')){
                if(sWHERE == null || sWHERE == ''){
                    sWHERE = ' WHERE';
                }
                sWHERE += glueOr+' (';
                String glueAND = '';
                if(oWrapper.selectedCompCode != null && oWrapper.selectedCompCode != ''){
                    sWHERE += ' WC_Code__c = \''+oWrapper.selectedCompCode+'\' ';
                    glueAND = ' AND ';
                }
                if(oWrapper.selectedState != null && oWrapper.selectedState != ''){
                    sWHERE += glueAND+' State__c = \''+oWrapper.selectedState+'\'';
                    glueAND = ' AND ';
                }
                if(oWrapper.selectedCarrier != null && oWrapper.selectedCarrier != ''){
                    sWHERE += glueAND+' Carrier__c = \''+oWrapper.selectedCarrier+'\'';
                    glueAND = ' AND ';
                }
                if(oWrapper.selectedStatus != null && oWrapper.selectedStatus != ''){
                    sWHERE += glueAND+' Status__c = \''+oWrapper.selectedStatus+'\'';
                }
                sWHERE += ') ';
                glueOr = ' OR ';
            }
        }
        
        
        if(sWHERE != null && sWHERE != ''){
            sSOQL += sWHERE;
            for(Carrier_WC_Rate__c oRate : database.query(sSOQL)){
                lstCarrierWCRates.add(oRate);
            }
        }
        
        return lstCarrierWCRates;
    }
    
    @AuraEnabled
    public static boolean isStateTerritorialRating(String filterJSON){
        boolean isRating = false;
        
        List<SearchWCCarrierRatesFilterWrapper> lstFilters = (List<SearchWCCarrierRatesFilterWrapper>)JSON.deserialize(filterJSON, List<SearchWCCarrierRatesFilterWrapper>.class);
        Set<String> setStateId = new Set<String>();
        for(SearchWCCarrierRatesFilterWrapper oWrapper : lstFilters){
            if(oWrapper.selectedState != null && oWrapper.selectedState != ''){
               setStateId.add(oWrapper.selectedState);
            }
        }
        
        if(setStateId.size()>0){
            for(State__c oState : [SELECT Id FROM State__c WHERE Id IN:setStateId  limit 1]){
                isRating = true;
            }
        }
        
        return isRating;
    }
    
    @AuraEnabled
    public static void updateCarrierWCRates(List<Carrier_WC_Rate__c> lstCarrierWCRates){
        try{
            update lstCarrierWCRates;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
}