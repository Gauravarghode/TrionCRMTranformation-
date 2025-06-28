public class ProposalPricingMatrix {
    
    public Proposal__c oProposal{get;set;} 
    
    public ProposalPricingMatrix(ApexPages.StandardController stdcon){ 

        Proposal__c prpsl = (Proposal__c)stdcon.getRecord();
        
        String SOQL = 'SELECT ';
        for(Proposal__c p : database.query(SOQL + getFields('Proposal__c') + ' FROM Proposal__c WHERE Id = \'' + prpsl.Id + '\'')){
             oProposal = p;
        } 
    }  
         
    public pageReference doProcess(){
        pageReference pr = null;
    
         try{
              // Pricing Matrix Logic
              List<Proposal__c> newList = new List<Proposal__c>();
              newList.add(oProposal);
              
              Map<Id, Proposal__c> oldMap = new Map<Id, Proposal__c>();
               
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
                            system.debug('====1====');
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
                                           //system.debug((Decimal)pro.get(pc.Field__c) + '====' + pc.Rule_Criteria__c + '====' + Decimal.valueof(pc.Value__c));
                                           
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
                
                update newList;
                
                pr = new pageReference('/' + oProposal.Id);
                
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return pr;
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