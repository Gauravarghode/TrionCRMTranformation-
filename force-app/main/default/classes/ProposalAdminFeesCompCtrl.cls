public class ProposalAdminFeesCompCtrl {

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
    public static Proposal__c getProposalDetails(String recordId){
        Proposal__c oProposal = new Proposal__c();
        for(Proposal__c pp : [SELECT Id,Admin_Fee_Gross_Wages__c,
                                Conga_Termination_Fee_Per_Employee__c,
                                EPLI_Maximum_Coverage_Limit_Per_Claim__c, NSF_Check_or_Reversed_ACH_Fee__c,
                                Replacement_Check_Fee__c, Total_Gross_Wages__c, Total_of_Employees__c,
                                Administrative_Fee_Type__c, Override_Gross_Wages_Admin_Fee__c,
                                Per_Check_Frequency__c, Admin_Fee_Per_Check__c, Admin_Fee_Annual__c,
                                Delivery_Fee_Per_Location__c, Delivery_Fee__c, Security_Deposit_Waived__c,
                                Security_Deposit__c, Client_Set_up_Fee_Waived__c, Client_Set_up_Fee__c,
                                Employee_New_Hire_Fee_Waived__c,Employee_New_Hire_Fee_Per_Employee__c,
                                EPLI_50_000_Deductible_Waived__c,EPLI_50_000_Deductible__c,
                                Worker_s_Compensation_Claims_Fee_waived__c,Worker_s_Compensation_Claims_Fee_Max__c,
                                Worker_s_Comp_Claims_Fee_Deposit_Waived__c,Worker_s_Compensation_Claims_Fee_Deposit__c,
                                Termination_Fee_Per_Employee_Waived__c,Termination_Fee_Per_Employee__c,
                                Termination_Fee_Per_Employee_Percentage__c,EPLI_Waived__c,
                                Employment_Practice_Liability_Insurance__c
                              FROM Proposal__c 
                              WHERE Id=:recordId]){
            oProposal = pp; 
        }
        return oProposal;
    }
    
    @AuraEnabled
    public static void updateProposal(Proposal__c oProposal){
        try{
            update oProposal;
        }catch(DMLException dmlex){
            throw new AuraException(dmlex.getDmlMessage(0));
        }catch(Exception ex){
            throw new AuraException(ex.getMessage());
        }
    }
    
}