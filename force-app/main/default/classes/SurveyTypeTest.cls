@isTest(SeeAllData=true)
public class SurveyTypeTest {

    @isTest
    public static void testCreateSurvey() {
        // Query active flows

        FlowRecord flow1 = [SELECT Id, FlowLabel, ApiName FROM FlowRecord WHERE ApiName = 'Question_Flow'];
        FlowRecord flow2 = [SELECT Id, FlowLabel, ApiName FROM FlowRecord WHERE ApiName ='Response_Capture'];  

        // Insert a Survey_Type__c record
        Survey_Type__c surveyType1 = new Survey_Type__c(
            Name = 'SurveyType1',
            Processing_Flow__c = flow1.Id,
            Response_Flow__c = flow2.Id
        );
        insert surveyType1;

        Survey_Type__c surveyType2 = new Survey_Type__c(
            Name = 'SurveyType2',
            Processing_Flow__c = flow1.Id,
            Response_Flow__c = flow2.Id
        );
        insert surveyType2;

        // Create a test Account
        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;

        // Mock payload
        Map<String, Object> payload = new Map<String, Object>{
            'surveyType' => surveyType1.Id,
            'processingFlow' => surveyType1.Processing_Flow__c,
            'responseFlow' => surveyType1.Response_Flow__c,
            'recordId' => testAccount.Id
        };

        // Test the createSurvey method
        Test.startTest();
        List<Survey_Type__c> surveyTypes = SurveyType.getSurveyTypeRecords();
        SurveyType.createSurvey(payload);
        Test.stopTest();

        // Query the survey record
        Survey__c createdSurvey = [
            SELECT Survey_Type__c, Account__c, Survey_URL__c
            FROM Survey__c
            WHERE Account__c = :testAccount.Id
            LIMIT 1
        ];
        
        String surveySiteURL = Label.SurveySiteURL;

       createdSurvey.Survey_URL__c  = Label.SurveySiteURL + '/?sid=' + createdSurvey.Id;
    update createdSurvey;

        // Assertions
        System.assertNotEquals(null, createdSurvey, 'Survey should have been created.');
        System.assertEquals(testAccount.Id, createdSurvey.Account__c, 'Account should match the test account.');
        System.assert(createdSurvey.Survey_URL__c.contains(createdSurvey.Id), 'Survey URL should contain the survey ID.');
    }
}