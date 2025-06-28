@isTest
public class PayrollSurveyControllerTest {
    @isTest
    static void testGetAccountAndContactDetails() {
        List<Contact> listOfContact = TestDataFactory.contactTestData2(false);
        try{
            List<Account> listOfAccounts = TestDataFactory.accountTestData(false);
            insert listOfAccounts;
            PayrollSurveyController.AccountWrapper accountWrapper = PayrollSurveyController.getAccountAndContactDetails(listOfAccounts[0].Id);
            System.assertEquals(1, [SELECT COUNT() FROM Account WHERE id =: listOfAccounts[0].id]); 
        }catch(Exception e){
            system.debug('Exception is '+e.getMessage());
        }
    }
    @isTest
    static void testGetCaseAndContactDetails() {       
        List<Contact> listOfContact = TestDataFactory.contactData1(false);
        try{
        List<Case> listOfCase = TestDataFactory.caseTestData(false);
        insert listOfCase;
        PayrollSurveyController.CaseWrapper caseWrapper = PayrollSurveyController.getCaseAndContactDetails(listOfCase[0].id);
            System.assertEquals(1, [SELECT COUNT() FROM Case WHERE id =: listOfCase[0].id]); 
        }catch(Exception e){
            system.debug('Exception is '+e.getMessage());
        }
    }  
}