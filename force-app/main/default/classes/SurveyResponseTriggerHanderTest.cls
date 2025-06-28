/*
 * Author: Rahul Nomula (EA)
 */

@isTest
public class SurveyResponseTriggerHanderTest {

    @isTest
    public static void runSurveyResponseTest(){

        List<Survey_Responses__c> surResList = new List<Survey_Responses__c>();
        try{
            surResList = TestDataFactory.surveyResponseData(true);
        } catch (Exception e){
            system.debug('Exception is '+e.getMessage());
        }
        //Check if the size of the survey responses is 1.
        System.assertEquals(1, [SELECT COUNT() FROM Survey_Responses__c WHERE Account__c =: surResList[0].Account__c]);
          //System.assertEquals(1, [SELECT COUNT() FROM Survey_Feedback__c WHERE Account__c =: surResList[0].Account__c]);

        //Use case: Insert another record and check if there is still only 1 survey response
        try{
            surResList = TestDataFactory.surveyResponseData(true);
        } catch (Exception e){
            system.debug('Exception is '+e.getMessage());
        }

        System.assertEquals(1, [SELECT COUNT() FROM Survey_Responses__c WHERE Case__c =: surResList[0].Case__c]);
    }
}