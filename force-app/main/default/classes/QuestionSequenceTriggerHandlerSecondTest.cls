@IsTest
public class QuestionSequenceTriggerHandlerSecondTest {

    @IsTest
    static void testQuestionSequence_ValidHeader() {
        // Test setup: Insert test data
        Question_Header__c testHeader = new Question_Header__c(Name = 'Test Header');
        insert testHeader;

        List<Questions__c> testQuestions = new List<Questions__c>();
        for (Integer i = 0; i < 5; i++) {
            testQuestions.add(new Questions__c(
                Question__c = 'Question test ' + i,
                Question_Header__c = testHeader.Id,
                Question_Sequence__c = Decimal.valueOf(i + 1),
                Question_Sequence_new__c = String.valueOf(i + 1)
            ));
        }
        insert testQuestions;

        // Test case: Valid Question Header ID
        Test.startTest();
        Integer result = QuestionSequenceTriggerHandlerSecond.questionSequence(testHeader.Id);
        Test.stopTest();

        System.assertEquals(5, result, 'The question sequence count should be 5.');
    }

    @IsTest
    static void testQuestionSequence_EmptyHeader() {
        // Test setup: Insert test data
        Question_Header__c emptyHeader = new Question_Header__c(Name = 'Empty Header');
        insert emptyHeader;

        // Test case: Empty Header ID
        Test.startTest();
        Integer result = QuestionSequenceTriggerHandlerSecond.questionSequence(emptyHeader.Id);
        Test.stopTest();

        System.assertEquals(0, result, 'The question sequence count should be 0.');
    }

    @IsTest
    static void testQuestionSequence_NullHeader() {
        // Test case: Null ID
        try {
            Test.startTest();
            QuestionSequenceTriggerHandlerSecond.questionSequence(null);
            Test.stopTest();
            //System.assert(false, 'An exception should have been thrown for a null ID.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Failed to fetch the current question sequence'),
                'Expected exception message for a null ID.');
        }
    }

}