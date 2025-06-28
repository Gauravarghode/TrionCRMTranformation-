@isTest
public class BatchtoPurgeCaseEmailTest {

       @isTest
    static void testCoverage() {
      Database.executeBatch(new BatchtoPurgeCaseEmail(), 2000);
    }
}