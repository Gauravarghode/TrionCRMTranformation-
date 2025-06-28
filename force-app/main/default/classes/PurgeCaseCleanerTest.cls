@isTest
public class PurgeCaseCleanerTest  {

    @isTest
    static void cleanerTest(){
        
        Database.executeBatch(new PurgeCaseCleaner(), 2000);
    }
}