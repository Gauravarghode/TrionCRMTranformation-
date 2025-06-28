/*
 * Author: Rahul Nomula (EA)
 */

@isTest
public class SurveyFeedbackTriggerHandlerTest {

    @isTest
    public static void runSurveyResponseTest(){

        List<Survey_Feedback__c> surFedList = new List<Survey_Feedback__c>();
        try{
            surFedList = TestDataFactory.surveyFeedbackData(true);
        } catch (Exception e){
            system.debug('Exception is '+e.getMessage());
        }
        System.assertEquals(1, [SELECT COUNT() FROM Survey_Feedback__c WHERE Case__c =: surFedList[0].Case__c]);
       // System.assertEquals(1, [SELECT COUNT() FROM Survey_Responses__c WHERE Case__c =: surFedList[0].Case__c]);

        
        try{
            surFedList = TestDataFactory.surveyFeedbackData(true);
        } catch (Exception e){
            system.debug('Exception is '+e.getMessage());
        }

        System.assertEquals(1, [SELECT COUNT() FROM Survey_Feedback__c WHERE Account__c =: surFedList[0].Account__c]);
    }
}