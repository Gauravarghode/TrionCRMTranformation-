public class NewEditPricingConditionExtension {
    
    public Pricing_Condition__c oPricingCondition{get;set;}
    public List<SelectOption> lstFieldOptions{get;set;}
    
    public NewEditPricingConditionExtension(ApexPages.StandardController stdcon){
        lstFieldOptions = new List<SelectOption>();
        lstFieldOptions.add(new SelectOption('', '-None-'));

        oPricingCondition = (Pricing_Condition__c)stdcon.getRecord();
        
        if(oPricingCondition != null && oPricingCondition.Id != null){
            for(Pricing_Condition__c pc : [SELECT Id, Name, Pricing_Matrix__c, Object__c, Field__c, Data_Type__c, Rule_Criteria__c, Value__c FROM Pricing_Condition__c WHERE Id=:oPricingCondition.Id]){
                oPricingCondition = pc;
            }
            
            if(oPricingCondition.Object__c != null && oPricingCondition.Object__c != ''){
                lstFieldOptions = new List<SelectOption>();
                Map<String , Schema.SObjectField> mapFieldList = Schema.getGlobalDescribe().get(oPricingCondition.Object__c).getDescribe().fields.getMap();
                
                MAP<string,string> mapFieldsName = new MAP<string,string>();
                List<string> lstFieldsName = new List<string>();
                for(Schema.SObjectField field : mapFieldList.values()){
                    DescribeFieldResult selectedField = field.getDescribe();
                    lstFieldsName.add(selectedField.getLabel());
                    mapFieldsName.put(selectedField.getLabel(),selectedField.getName()); 
                }
                if(lstFieldsName.size() > 0){
                    lstFieldsName.sort();
                    for(string strFN : lstFieldsName){ 
                        lstFieldOptions.add(new SelectOption(mapFieldsName.get(strFN), strFN));
                    }
                }
            }
        }
    }  
        
    
    public pageReference getFieldOptions(){
        oPricingCondition.Field__c = null;
        oPricingCondition.Data_Type__c = null;
        lstFieldOptions = new List<SelectOption>();
        lstFieldOptions.add(new SelectOption('', '-None-'));
        if(oPricingCondition.Object__c != null && oPricingCondition.Object__c != ''){
            Map<String , Schema.SObjectField> mapFieldList = Schema.getGlobalDescribe().get(oPricingCondition.Object__c).getDescribe().fields.getMap();
            
            MAP<string,string> mapFieldsName = new MAP<string,string>();
            List<string> lstFieldsName = new List<string>();
            for(Schema.SObjectField field : mapFieldList.values()){
                DescribeFieldResult selectedField = field.getDescribe();
                lstFieldsName.add(selectedField.getLabel());
                mapFieldsName.put(selectedField.getLabel(),selectedField.getName()); 
            }
            if(lstFieldsName.size() > 0){
                lstFieldsName.sort();
                for(string strFN : lstFieldsName){ 
                    lstFieldOptions.add(new SelectOption(mapFieldsName.get(strFN), strFN));
                }
            }
             
        }
        return null;
    }
    
    public pageReference getFieldType(){
        oPricingCondition.Data_Type__c = null;
        Map<String , Schema.SObjectField> mapFieldList = Schema.getGlobalDescribe().get(oPricingCondition.Object__c).getDescribe().fields.getMap();
        for(Schema.SObjectField field : mapFieldList.values()){
            DescribeFieldResult selectedField = field.getDescribe();
            if(selectedField.getName() == oPricingCondition.Field__c){
                String fieldType = String.valueOf(selectedField.getType()).toLowerCase();
                if(fieldType == 'boolean'){
                    oPricingCondition.Data_Type__c = 'Boolean';
                }else if(fieldType == 'date' || fieldType == 'datetime'){
                    oPricingCondition.Data_Type__c = 'Date';
                }else if(fieldType == 'double'||fieldType == 'integer'||fieldType == 'long'){
                    oPricingCondition.Data_Type__c = 'Decimal';
                }else{
                    oPricingCondition.Data_Type__c = 'String';
                }
            }
        }
        return null;
    }
    
    public pageReference doSave(){
        try{
            upsert oPricingCondition;
            return new pageReference('/'+oPricingCondition.Id);
        }catch(DMLException dmlex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlex.getDmlMessage(0)));
            return null;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    public pageReference doSaveAndNew(){
         try{
             upsert oPricingCondition;
             oPricingCondition = new Pricing_Condition__c();
             lstFieldOptions = new List<SelectOption>();
             lstFieldOptions.add(new SelectOption('', '-None-'));
        }catch(DMLException dmlex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlex.getDmlMessage(0)));
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }

}