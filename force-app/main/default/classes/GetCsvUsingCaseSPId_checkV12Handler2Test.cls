@isTest
public class GetCsvUsingCaseSPId_checkV12Handler2Test {
    
    @isTest
    static void testCoverage(){
        GetCsvUsingCaseSPId_checkV12Handler2_V2.testCoverage();
    }
    
    @isTest
    static void testTriggerExecution() {
        
        
        List<ListMapPlatform__e> events = new List<ListMapPlatform__e>();
        events.add(new ListMapPlatform__e(csvInfoList__c = 'email1@example.com'));
        events.add(new ListMapPlatform__e(csvInfoList__c = 'email2@example.com'));
        
        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();
        
        
        
    }
}