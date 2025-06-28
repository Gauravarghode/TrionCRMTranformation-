/**
* @File Name : surveyType.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : December 6, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 6, 2024 |   | Initial Version
**/

public class SurveyType {
    @AuraEnabled(cacheable=true)
    public static List<Survey_Type__c> getSurveyTypeRecords() {
        // Return available custom metadata types (e.g., __mdt types)
        List<Survey_Type__c> surveyType = [
            SELECT Name, Processing_Flow__c, Response_Flow__c
            FROM Survey_Type__c
        ];
        System.debug('Survey Type:' +surveyType);
        return surveyType;
    }

    @AuraEnabled
public static void createSurvey(Map<String, Object> payload) {

    system.debug('Payload:' +payload);

    String surveyType = (String) payload.get('surveyType');
    String processingFlow = (String) payload.get('processingFlow');
    String responseFlow = (String) payload.get('responseFlow');
    Id recordId = (Id) payload.get('recordId');

    System.debug('Survey Type: ' + surveyType);
    System.debug('Processing Flow: ' + processingFlow);
    System.debug('Response Flow: ' + responseFlow);
    System.debug('Record ID: ' + recordId);

    Survey__c survey = new Survey__c();
    survey.Survey_Type__c = surveyType;
    survey.Account__c = recordId;
    // survey.Case__c = recordId;

    insert survey;

    String surveySiteURL = Label.SurveySiteURL;

    // Update the survey with the URL
    // survey.Survey_URL__c = 'https://trion--uat.sandbox.my.site.com/?sid=' + survey.Id;
    survey.Survey_URL__c  = Label.SurveySiteURL + '/?sid=' + survey.Id;
    update survey;
}
}