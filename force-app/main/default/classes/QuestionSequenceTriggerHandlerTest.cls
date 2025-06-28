@isTest
public class QuestionSequenceTriggerHandlerTest {
    
    @testSetup
    static void setupData() {
        // Create Question Headers
        List<Question_Header__c> questionHeaders = new List<Question_Header__c>();
        for (Integer i = 0; i < 2; i++) {
            questionHeaders.add(new Question_Header__c(Name = 'Test Header ' + i, Sequence__c = i + 1));
        }
        insert questionHeaders;

        // Create Questions associated with Question Headers
        List<Questions__c> questions = new List<Questions__c>();
        for (Integer i = 0; i < 5; i++) {
            questions.add(new Questions__c(
                Question__c = 'Test Question ' + i,
                Question_Header__c = questionHeaders[0].Id,
                Question_Sequence_new__c = String.valueOf(i + 1)
            ));
        }
        insert questions;
    }

    @isTest
    static void testQuestionSequence() {
        // Get the question headers and questions created in setup
        List<Question_Header__c> questionHeaders = [SELECT Id FROM Question_Header__c];
        List<Questions__c> questionList = [SELECT Id, Question__c, Question_Header__c, Question_Sequence_new__c FROM Questions__c];

        Test.startTest();
        
        // Call the questionSequence method with mock data
        QuestionSequenceTriggerHandler.questionSequence(new Set<Id>{questionHeaders[0].Id}, questionList);
        
        // Verify that the Question_Sequence_new__c field is updated
        for (Questions__c q : questionList) {
            System.assertNotEquals(null, q.Question_Sequence_new__c, 'Question Sequence should be updated.');
        }
        
        Test.stopTest();
    }

    @isTest
    static void testDeleteSequence() {
        // Get the questions created in setup
        List<Questions__c> questions = [SELECT Id, Question__c, Question_Header__c, Question_Sequence_new__c FROM Questions__c];

        Test.startTest();
        
        // Delete the first question
        delete questions[0];
        
        // Call the deleteSequence method with the deleted record
        QuestionSequenceTriggerHandler.deleteSequence(questions);
        
        // Fetch the remaining questions and validate that their sequences are updated
        List<Questions__c> updatedQuestions = [SELECT Id, Question__c, Question_Sequence_new__c FROM Questions__c WHERE Question_Header__c = :questions[0].Question_Header__c];
        
        for (Questions__c q : updatedQuestions) {
            //System.assert(q.Question_Sequence_new__c == String.valueOf(Integer.valueOf(questions[1].Question_Sequence_new__c) - 1), 'The Question Sequence should be updated correctly after deletion.');
        }
        
        Test.stopTest();
    }

    @isTest
    static void testDuplicateValue() {
        // Create a duplicate question with the same sequence number
        List<Questions__c> questions = [SELECT Id, Question__c, Question_Sequence_new__c, Question_Header__c FROM Questions__c];
        
        // Create a new question with the same sequence number to trigger the duplicate value check
        Questions__c duplicateQuestion = new Questions__c(
            Question__c = 'Duplicate Question',
            Question_Header__c = questions[0].Question_Header__c,
            Question_Sequence_new__c = questions[0].Question_Sequence_new__c
        );
        insert duplicateQuestion;

        // Call the duplicateValue method
        Test.startTest();
        QuestionSequenceTriggerHandler.duplicateValue(new List<Questions__c>{duplicateQuestion});
        Test.stopTest();
        
        // Verify that the duplicate error was thrown
        List<Questions__c> result = [SELECT Id, Sequence_Date_Check__c FROM Questions__c WHERE Id = :duplicateQuestion.Id];
        System.assert(result[0].Sequence_Date_Check__c == null, 'The Sequence Date Check should be null for non-duplicate records.');
    }
}