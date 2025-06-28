public class ProposalTriggerHandler {
    public static void onBeforeInsert(List<Proposal__c> newList){
        handlePricingMatrix(newList, null);
    }
    
    public static void onBeforeUpdate(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap){
        handlePricingMatrix(newList, oldMap);
    }
    
    // Pricing Matrix Logic
    public static void handlePricingMatrix(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap){
         
        SET<string> setProposalStage = new SET<string>();
        Set<Id> setOpportunityId = new Set<Id>();
        Set<Id> setAccountId = new Set<Id>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();

        for(Proposal__c pro: newList){
            if(pro.Stage__c != null){
                setProposalStage.add(pro.Stage__c);
            } 
            setOpportunityId.add(pro.Opportunity__c);
        }

        String SOQL = 'SELECT ';
        if(setOpportunityId.size() > 0){
            for(Opportunity opp : database.query(SOQL + getFields('Opportunity') + ' FROM Opportunity WHERE Id IN : setOpportunityId ')){
                mapOpportunity.put(opp.Id, opp);
                if(opp.AccountId != null){
                    setAccountId.add(opp.AccountId);
                }
            }
            if(setAccountId.size() > 0){
                for(Account acc : database.query(SOQL + getFields('Account') + ' FROM Account WHERE Id IN : setAccountId ')){
                    mapAccount.put(acc.Id, acc);
                }
            }
        }

        List<Pricing_Matrix__c> listPMatrix = [Select Id,Stage__c, 
                                                (Select Id, Data_Type__c,Object__c,Field__c, Rule_Criteria__c,Value__c From Pricing_Conditions__r) 
                                                From Pricing_Matrix__c Where Status__c = 'Active' AND Stage__c IN: setProposalStage Order By Order__c ASC];


        for(Proposal__c pro: newList){
            if(pro.Stage__c != null){

                for(Pricing_Matrix__c pm : listPMatrix){ 
                    system.debug('====2====');
                    if(pro.Stage__c == pm.Stage__c){
                        boolean matching = true;
                        Opportunity opp = mapOpportunity.get(pro.Opportunity__c);
                        Account acc = mapAccount.get(mapOpportunity.get(pro.Opportunity__c).AccountId);

                        for(Pricing_Condition__c pc: pm.Pricing_Conditions__r){ 
 
                            if(pc.Object__c == 'Proposal__c'){
                               if(pc.Data_Type__c == 'String' ){
                                   
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (string)pro.get(pc.Field__c) != pc.Value__c) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (string)pro.get(pc.Field__c) == pc.Value__c) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Decimal' ){
                                   system.debug('========');
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Decimal)pro.get(pc.Field__c) != Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Decimal)pro.get(pc.Field__c) == Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN' && (Decimal)pro.get(pc.Field__c) >= Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN' && (Decimal)pro.get(pc.Field__c) <= Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN OR EQUAL' && (Decimal)pro.get(pc.Field__c) > Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN OR EQUAL' && (Decimal)pro.get(pc.Field__c) < Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Date' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Date)pro.get(pc.Field__c) != Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Date)pro.get(pc.Field__c) == Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN' && (Date)pro.get(pc.Field__c) >= Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN' && (Date)pro.get(pc.Field__c) <= Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN OR EQUAL' && (Date)pro.get(pc.Field__c) > Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN OR EQUAL' && (Date)pro.get(pc.Field__c) < Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Boolean' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Boolean)pro.get(pc.Field__c) != Boolean.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Boolean)pro.get(pc.Field__c) == Boolean.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                            }
                            if(pc.Object__c == 'Opportunity'){
                               if(pc.Data_Type__c == 'String' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (string)opp.get(pc.Field__c) != pc.Value__c) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (string)opp.get(pc.Field__c) == pc.Value__c) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Decimal' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Decimal)opp.get(pc.Field__c) != Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Decimal)opp.get(pc.Field__c) == Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN' && (Decimal)opp.get(pc.Field__c) >= Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN' && (Decimal)opp.get(pc.Field__c) <= Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN OR EQUAL' && (Decimal)opp.get(pc.Field__c) > Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN OR EQUAL' && (Decimal)opp.get(pc.Field__c) < Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Date' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Date)opp.get(pc.Field__c) != Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Date)opp.get(pc.Field__c) == Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN' && (Date)opp.get(pc.Field__c) >= Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN' && (Date)opp.get(pc.Field__c) <= Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN OR EQUAL' && (Date)opp.get(pc.Field__c) > Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN OR EQUAL' && (Date)opp.get(pc.Field__c) < Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Boolean' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Boolean)opp.get(pc.Field__c) != Boolean.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Boolean)opp.get(pc.Field__c) == Boolean.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                            }

                            if(pc.Object__c == 'Account'){
                               if(pc.Data_Type__c == 'String' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (string)acc.get(pc.Field__c) != pc.Value__c) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (string)acc.get(pc.Field__c) == pc.Value__c) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Decimal' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Decimal)acc.get(pc.Field__c) != Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Decimal)acc.get(pc.Field__c) == Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN' && (Decimal)acc.get(pc.Field__c) >= Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN' && (Decimal)acc.get(pc.Field__c) <= Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN OR EQUAL' && (Decimal)acc.get(pc.Field__c) > Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN OR EQUAL' && (Decimal)acc.get(pc.Field__c) < Decimal.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Date' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Date)acc.get(pc.Field__c) != Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Date)acc.get(pc.Field__c) == Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN' && (Date)acc.get(pc.Field__c) >= Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN' && (Date)acc.get(pc.Field__c) <= Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'LESS THAN OR EQUAL' && (Date)acc.get(pc.Field__c) > Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'GREATER THAN OR EQUAL' && (Date)acc.get(pc.Field__c) < Date.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                               else if(pc.Data_Type__c == 'Boolean' ){
                                    if(pc.Rule_Criteria__c == 'EQUALS' && (Boolean)acc.get(pc.Field__c) != Boolean.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                                    else if(pc.Rule_Criteria__c == 'NOT EQUALS' && (Boolean)acc.get(pc.Field__c) == Boolean.valueof(pc.Value__c)) {
                                        matching = false;  
                                    }
                               }
                            } 
                        }

                         if(matching == true){
                            pro.Pricing_Matrix__c = pm.Id;    
                            break;   
                         } 
                    }
                }
            }
        }
 
    }
    
    public static void afterUpdate(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap){

        Set<String> setProposalId = new Set<String>();
        Set<String> setProposalYearId = new Set<String>();
        Set<String> setStateId = new Set<String>();
        List<SUTA_Quote__c> lstSUTAQuote = new List<SUTA_Quote__c>();
        List<SUTA_Quote__c> lstSUTAQuoteToUpdate = new List<SUTA_Quote__c>();
        Map<String, SUTA__c> mapSUTA = new Map<String, SUTA__c>();
        
        for(Proposal__c oProposal : newList){
            if(oProposal.Year__c != null && oldMap.get(oProposal.Id).Year__c != oProposal.Year__c){
                setProposalId.add(oProposal.Id);
            }
        }
        
        if(setProposalId.size()>0){
            for(SUTA_Quote__c oQuote : [SELECT Id, SUTA__c, State__c, Proposal__r.Year__c 
                                        FROM SUTA_Quote__c 
                                        WHERE Proposal__c IN : setProposalId]){
                 if(oQuote.Proposal__r.Year__c!=null){
                      setProposalYearId.add(oQuote.Proposal__r.Year__c);
                 }
                 if(oQuote.State__c != null){
                    setStateId.add(oQuote.State__c);
                 }
                lstSUTAQuote.add(oQuote);
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
        
        if(lstSUTAQuote.size()>0 && !mapSUTA.isEmpty()){
            for(SUTA_Quote__c oQuote : lstSUTAQuote){
                if(oQuote.State__c != null && oQuote.Proposal__r.Year__c != null){
                    if(mapSUTA.containsKey(oQuote.State__c+'_'+oQuote.Proposal__r.Year__c+'_Trion2')){
                        oQuote.SUTA__c = mapSUTA.get(oQuote.State__c+'_'+oQuote.Proposal__r.Year__c+'_Trion2').Id;
                        lstSUTAQuoteToUpdate.add(oQuote);
                    }else if(mapSUTA.containsKey(oQuote.State__c+'_'+oQuote.Proposal__r.Year__c+'_Trion')){
                        oQuote.SUTA__c = mapSUTA.get(oQuote.State__c+'_'+oQuote.Proposal__r.Year__c+'_Trion').Id;
                        lstSUTAQuoteToUpdate.add(oQuote);
                    }
                }
            }
        }
        
        if(lstSUTAQuoteToUpdate.size()>0){
            update lstSUTAQuoteToUpdate;
        }
    }
    
    private static String getFields(String objectName){
        String fields = '';
        String glue = '';
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult sObjectResult = sobjType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = sObjectResult.fields.getMap();
        
        for(String fieldName : mapFields.keySet()) {
            fields += glue + String.valueOf(mapFields.get(fieldName));
            glue = ',';
        }
        return fields;
    }
    

}