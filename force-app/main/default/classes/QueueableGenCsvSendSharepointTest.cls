@IsTest
public class QueueableGenCsvSendSharepointTest {

    @TestSetup
    static void setup() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            have_more_character__c = true,
            ContactId = testContact.Id
        );
        insert testCase;

        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Integer i = 0; i < 30; i++) {
            EmailMessage em = new EmailMessage();
            em.ParentId = testCase.Id;
            em.Subject = 'Test Subject ' + i;
            em.TextBody = 'Test Body ' + i;
            emailMessages.add(em);
        }
        insert emailMessages;
    }
/*
    @IsTest
    static void testQueueableGenCsvSendSharepoint() {
        QueueableGenCsvSendSharepoint.doChainJob = false;
        Test.startTest();
        QueueableGenCsvSendSharepoint.invokeQueueable();
        Test.stopTest();
      
    }
*/
     @isTest
    static void testCoverage() {
        Test.startTest();
        QueueableGenCsvSendSharepoint.testCoverage();
        Test.stopTest();
    }

}