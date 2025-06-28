@isTest
Private class Arch_PopuPurgeLogsEmailsTest {
    @testSetup static void testCreateCaseAndSendEmail() {
        //TestFactoryClass.createCases();
        TestFactoryClass.sendEmailsWithAttachments(TestFactoryClass.createCases());
    }
    @isTest Static void purgeEmailSkBatchTestMethod(){
        Test.startTest();
            Arch_PopuPurgeLogsEmails bc=New Arch_PopuPurgeLogsEmails();
            DataBase.ExecuteBatch(bc);
        	Arch_PopuPurgeLogsEmails.testCoverage();
        Test.stopTest();
    }
}