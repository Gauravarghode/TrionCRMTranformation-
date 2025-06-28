/**
* @File Name : runningFlows.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : December 9, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 9, 2024 |   | Initial Version
**/

public class runningFlows {
	 @AuraEnabled(cacheable=true)
public static Map<String, Object> getRecordDetails(String sid) {
    Map<String, Object> result = new Map<String, Object>();

    // Fetch the Survey__c record
    List<Survey__c> surveyRecords = [
        SELECT Id, Name, Account__c, Survey_Type__c, Survey_Type__r.Name, Surveyed__c
        FROM Survey__c
        WHERE Id = :sid
        LIMIT 1
    ];
    if (!surveyRecords.isEmpty()) {
        Survey__c surveyRecord = surveyRecords[0];
        result.put('SurveyRecord', surveyRecord);

        // Fetch the related Survey_Type__c record
        List<Survey_Type__c> surveyTypeRecords = [
            SELECT Id, Name, Processing_Flow__c, Processing_Flow__r.ApiName, 
                   Response_Flow__c, Response_Flow__r.ApiName
            FROM Survey_Type__c
            WHERE Name = :surveyRecord.Survey_Type__r.Name
            LIMIT 1
        ];
        if (!surveyTypeRecords.isEmpty()) {
            result.put('SurveyTypeRecord', surveyTypeRecords[0]);
        }
    }
    return result;
}
}