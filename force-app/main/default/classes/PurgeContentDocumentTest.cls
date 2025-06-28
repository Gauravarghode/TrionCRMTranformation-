@isTest
public class PurgeContentDocumentTest {

    @isTest
    static void cleanerTest(){
        
        Database.executeBatch(new PurgeContentDocument(), 2000);
    }
}