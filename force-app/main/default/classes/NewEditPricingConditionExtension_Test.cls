@isTest
public class NewEditPricingConditionExtension_Test {

    @isTest
    public static void myUnitTest(){
        Pricing_Matrix__c pm = new Pricing_Matrix__c();
        pm.Stage__c = 'Quoting';
        pm.Status__c = 'Active';
        insert pm;
        
        Pricing_Condition__c oPricing_Condition = new Pricing_Condition__c();
        oPricing_Condition.Pricing_Matrix__c = pm.Id;
        oPricing_Condition.Object__c = 'Account';
        oPricing_Condition.Field__c = 'Name';
        oPricing_Condition.Data_Type__c = 'String';
        oPricing_Condition.Rule_Criteria__c = 'EQUALS';
        oPricing_Condition.Value__c = '10';
        
        PageReference pageRef = Page.NewEditPricingConditionPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oPricing_Condition);
        NewEditPricingConditionExtension testAccPlan = new NewEditPricingConditionExtension(sc);
        testAccPlan.doSave();
        testAccPlan.doSaveAndNew();
        oPricing_Condition.Object__c = 'Account';
        oPricing_Condition.Field__c = 'Name';
        oPricing_Condition.Data_Type__c = 'String';
        testAccPlan.oPricingCondition = oPricing_Condition;
        testAccPlan.getFieldType();
        testAccPlan.getFieldOptions();
        try{
            testAccPlan.oPricingCondition = null;
            testAccPlan.doSave();
        }catch(exception ex){
            
        }
        
        try{
            testAccPlan.oPricingCondition = null;
            testAccPlan.doSaveAndNew();
        }catch(exception ex){
            
        }
    }
    
    @isTest
    public static void myUnitTest1(){
        Pricing_Matrix__c pm = new Pricing_Matrix__c();
        pm.Stage__c = 'Quoting';
        pm.Status__c = 'Active';
        insert pm;
        
        Pricing_Condition__c oPricing_Condition = new Pricing_Condition__c();
        oPricing_Condition.Pricing_Matrix__c = pm.Id;
        oPricing_Condition.Object__c = 'Account';
        oPricing_Condition.Field__c = 'Name';
        oPricing_Condition.Data_Type__c = 'String';
        oPricing_Condition.Rule_Criteria__c = 'EQUALS';
        oPricing_Condition.Value__c = '10';
        insert oPricing_Condition;
        
        PageReference pageRef = Page.NewEditPricingConditionPage;
        pageRef.getParameters().put('id', String.valueOf(oPricing_Condition.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oPricing_Condition);
        NewEditPricingConditionExtension testAccPlan = new NewEditPricingConditionExtension(sc);
        testAccPlan.doSave();
    }
    
}