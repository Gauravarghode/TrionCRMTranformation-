@isTest(SeeAllData=true)
public class RunningFlowsTest {

    @isTest
    public static void testGetRecordDetails() {
        
         FlowRecord flow1 = [SELECT Id, FlowLabel, ApiName FROM FlowRecord WHERE ApiName = 'Question_Flow'];
        FlowRecord flow2 = [SELECT Id, FlowLabel, ApiName FROM FlowRecord WHERE ApiName ='Response_Capture']; 
        
        // Setup: Create test records
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Survey_Type__c testSurveyType = new Survey_Type__c(
            Name = 'Test Survey Type',
            Processing_Flow__c = flow1.Id,
            Response_Flow__c = flow2.Id
        );
        insert testSurveyType;

        Survey__c testSurvey = new Survey__c(
            Account__c = testAccount.Id,
            Survey_Type__c = testSurveyType.Id
        );
        insert testSurvey;

        // Test the getRecordDetails method
        Test.startTest();
        Map<String, Object> result = runningFlows.getRecordDetails(testSurvey.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assert(result.containsKey('SurveyRecord'), 'Result should contain SurveyRecord.');
        System.assert(result.containsKey('SurveyTypeRecord'), 'Result should contain SurveyTypeRecord.');

        Survey__c surveyRecord = (Survey__c) result.get('SurveyRecord');
        System.assertEquals(testSurvey.Id, surveyRecord.Id, 'Survey record ID should match.');
        //System.assertEquals('Test Survey', surveyRecord.Name, 'Survey name should match.');

        Survey_Type__c surveyTypeRecord = (Survey_Type__c) result.get('SurveyTypeRecord');
        System.assertEquals(testSurveyType.Id, surveyTypeRecord.Id, 'Survey Type record ID should match.');
        System.assertEquals('Test Survey Type', surveyTypeRecord.Name, 'Survey Type name should match.');
    }

}