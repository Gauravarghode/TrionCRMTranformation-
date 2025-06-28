@isTest
public class ContactTriggerHandlerTest {
    @isTest
    static void test() {
       List<Contact> conlist = TestDataFactory.contactData(True);
       System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Id =: conlist[0].Id]);
      	
    }

}