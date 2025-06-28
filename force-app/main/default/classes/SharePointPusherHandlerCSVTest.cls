@isTest()
public class SharePointPusherHandlerCSVTest{
    
    @isTest
    public static void platformEventsTestData(){
       /* List<EmailMessage_Html__b> stagingRecords = new List<EmailMessage_Html__b>();
        for (Integer i = 0; i <5; i++) {
            EmailMessage_Html__b stagingRecord = new EmailMessage_Html__b(Status__c = 'Not Started', EmailMessage_Id__c = '1234567890', sObject__c='EmailMessage');
            stagingRecords.add(stagingRecord);
        }
      */  
        List<SharePointPusherCSV__e> sharePointPushInsert = new List<SharePointPusherCSV__e>();
        for( integer i=0;i>60;i++){
            SharePointPusherCSV__e ap = new SharePointPusherCSV__e();
            ap.EmailNumber__c = 'Chunk ' + i;
            sharePointPushInsert.add(ap);
        }
        Eventbus.publish(sharePointPushInsert);
        Test.startTest();
        Arch_SharePointPusherHandlerCSV.subscribeEvents(sharePointPushInsert);
        Arch_SharePointPusherHandlerCSV.testCoverage();
        Test.stopTest();
    } 
}