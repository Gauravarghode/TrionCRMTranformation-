@isTest
public class GetCsvUsingCaseSPId_checkV12HandlerTest {
    
    @isTest
    static void testCoverage(){
        GetCsvUsingCaseSPId_checkV12Handler_V2.testCoverage();
    }
        @isTest
    static void testTriggerExecution() {


        List<ListMapPlatform_V2__e> events = new List<ListMapPlatform_V2__e>();
        events.add(new ListMapPlatform_V2__e(Id__c = '02sjweiuh7y7yoiwu' , ParentId__c = '500hgwd72dye1'));
        events.add(new ListMapPlatform_V2__e(Id__c = '02sjweiliwefjuiSS' , ParentId__c = '500hgwd7wdye1'));

        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();


      
    }
    
}