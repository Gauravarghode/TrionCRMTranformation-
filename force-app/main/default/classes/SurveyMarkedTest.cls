/**
* @File Name : SurveyMarkedTest .cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : January 31, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 31, 2025 |   | Initial Version
**/

@isTest
private class SurveyMarkedTest {
    @isTest
    static void testSurveyMarked_Success() {
        // Arrange: Create a survey record
        Survey__c survey = new Survey__c();
        insert survey;

        // Act: Call the method with the survey ID
        Test.startTest();
        SurveyMarked.surveyMarked(survey.Id);
        Test.stopTest();

        // Assert: Verify that the Surveyed__c field is updated
        Survey__c updatedSurvey = [SELECT Id, Surveyed__c FROM Survey__c WHERE Id = :survey.Id];
        System.assertEquals(true, updatedSurvey.Surveyed__c, 'The Surveyed__c field should be updated to true.');
    }

    @isTest
    static void testSurveyMarked_BlankId() {
        // Act & Assert: Call the method with a blank ID and verify exception is thrown
        Test.startTest();
        try {
            SurveyMarked.surveyMarked('');
            System.assert(false, 'Expected an exception to be thrown for a blank ID.');
        } catch (IllegalArgumentException e) {
            System.assertEquals('No survey IDs provided.', e.getMessage(), 'Exception message should match.');
        }
        Test.stopTest();
    }
}