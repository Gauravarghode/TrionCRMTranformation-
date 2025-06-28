/*public class QuestionSequenceTriggerHandlerSecond {

@AuraEnabled
public static Integer questionSequence(Id questionHeaderId) {

integer addVal;
List<Questions__c> existingQuestionList = [SELECT Id, Question_Header__c, Question_Sequence__c, Question_Sequence_Test__c, Question_Sequence_new__c 
FROM Questions__c WHERE Question_Header__c =:questionHeaderId ORDER BY Question_Sequence_Test__c ASC];
Integer existiungQuestionsSize = existingQuestionList.size();
system.debug('existiungQuestionsSize is==== >' +existiungQuestionsSize);

return existiungQuestionsSize;
}
}*/


public class QuestionSequenceTriggerHandlerSecond {
    
    @AuraEnabled
    public static Integer questionSequence(Id questionHeaderId) {
        // Check if the questionHeaderId is null
        if (String.isBlank(questionHeaderId)) {
            System.debug('Error: questionHeaderId is null or blank.');
            return 0; // Or throw a custom exception
        }
        
        try {
            // Query the existing questions for the given header
            List<Questions__c> existingQuestionList = [
                SELECT Id, Question_Header__c, Question__c, Question_Sequence__c, Question_Sequence_Test__c, Question_Sequence_new__c 
                FROM Questions__c 
                WHERE Question_Header__c = :questionHeaderId 
                ORDER BY Question_Sequence_new__c ASC
            ];
            
            Integer existingQuestionsSize = existingQuestionList.size();
            System.debug('Existing Questions Size: ' + existingQuestionsSize);
            
            // Return the count of existing questions
            return existingQuestionsSize;
            
        } catch (Exception e) {
            System.debug('Error in questionSequence: ' + e.getMessage());
            // Optionally, throw a custom exception or return a default value
            throw new AuraHandledException('Failed to fetch the current question sequence. ' + e.getMessage());
        }
    }
}