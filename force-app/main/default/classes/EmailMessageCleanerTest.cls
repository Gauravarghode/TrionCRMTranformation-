@IsTest
public class EmailMessageCleanerTest {
   
     @isTest
    static void cleanerTest(){
        
        Database.executeBatch(new EmailMessageCleaner(), 2000);
    }
}