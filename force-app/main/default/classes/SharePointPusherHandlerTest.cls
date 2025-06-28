@isTest()
public class SharePointPusherHandlerTest{
    
    @isTest
    public static void platformEventsTestData(){
      /*  List<Staging__b> stagingRecords = new List<Staging__b>();
        for (Integer i = 0; i <5; i++) {
            Staging__b stagingRecord = new Staging__b(Status__c = 'Not Started', Chunk__c = 'Test##SP');
            stagingRecords.add(stagingRecord);
        }
      */  
        List<SharePointPusher__e> sharePointPushInsert = new List<SharePointPusher__e>();
        for( integer i=0;i>60;i++){
            SharePointPusher__e ap = new SharePointPusher__e();
            ap.ChunkNumber__c = 'Chunk ' + i;
            sharePointPushInsert.add(ap);
        }
        Eventbus.publish(sharePointPushInsert);
        Test.startTest();
        Arch_SharePointPusherHandlerFA.subscribeEvents(sharePointPushInsert);
        Arch_SharePointPusherHandlerFA.testCoverage();
        Test.stopTest();
    } 
}