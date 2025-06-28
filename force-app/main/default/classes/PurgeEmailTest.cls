@isTest
public class PurgeEmailTest {

    @isTest
    static void cleanerTest(){
        
        Database.executeBatch(new PurgeEmail(), 2000);
    }
}