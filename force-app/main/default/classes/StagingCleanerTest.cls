@isTest
public class StagingCleanerTest {

    @isTest
    static void cleanerTest(){
        
        Database.executeBatch(new StagingCleaner(), 2000);
    }
}