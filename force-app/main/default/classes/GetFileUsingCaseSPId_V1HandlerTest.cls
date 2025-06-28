@isTest
public class GetFileUsingCaseSPId_V1HandlerTest {
    
    @isTest
    static void testCoverage(){
        GetFileUsingCaseSPId_V1Handler.testCoverage();
    }
    
        @isTest
    static void testTriggerExecution() {


        List<FileListMapPlatform__e> events = new List<FileListMapPlatform__e>();
        events.add(new FileListMapPlatform__e(fileDataPlatform__c = 'email1@example.com'));
        events.add(new FileListMapPlatform__e(fileDataPlatform__c = 'email2@example.com'));

        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();


      
    }
    
}