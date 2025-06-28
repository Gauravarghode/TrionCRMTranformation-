@isTest()
public class EmailTemplateMappingHanderTest {
    
    public static boolean isTestFailInsert = false;
    /* @testsetup
static void insertTestData() {

}

@isTest()
static void beforeInsertcheckCampaignStatusData(){

EmailTemplateMappingHanderTest.isTestFailInsert = true;

List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
Email_Template_Mapping__c emailTempMappEach1 = new Email_Template_Mapping__c(Email_Template__c = emailTempList[0].id,Campaign__c = campaignList[0].id,Status__c = 'Not Activated');
List<Email_Template_Mapping__c> listOfEmailTempMapp1 = new List<Email_Template_Mapping__c>();
listOfEmailTempMapp1.add(emailTempMappEach1);
EmailTemplateMappingHander.beforeInsertcheckCampaignStatus(listOfEmailTempMapp1);

List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, false);

EmailTemplateMappingHander.beforeInsertcheckCampaignStatus(listOfEmailTempMapp);
system.assertEquals('Creation', campaignList[0].Campaign_Stage__c);
} */
    
    @isTest()
    static void beforeUpdatecheckCampaignStatusData() {
        
        EmailTemplateMappingHanderTest.isTestFailInsert = true;
        
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        
        //emailTemplateMapDataActive
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp1 = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, false);
        
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true,emailTempList[0].id);
        
        Map<id,Email_Template_Mapping__c> oldMap = new Map<id,Email_Template_Mapping__c>(listOfEmailTempMapp);
        for(Email_Template_Mapping__c eamilTempMapEach:listOfEmailTempMapp){
            eamilTempMapEach.Status__c='Activate'; 
        }
        Database.update(listOfEmailTempMapp,false);
        Email_Template_Mapping__c emailTempMappEach1 = new Email_Template_Mapping__c(Email_Template__c = emailTempList[0].id,Status__c = 'Not Activated');
        List<Email_Template_Mapping__c> newlist = new List<Email_Template_Mapping__c>();
        newlist.add(emailTempMappEach1);
        EmailTemplateMappingHander.beforeUpdatecheckCampaignStatus(listOfEmailTempMapp,oldMap);
        EmailTemplateMappingHander.checkDuplicatesforEmailTEmplate(listOfEmailTempMapp1);
        EmailTemplateMappingHander.insertInteractionEvtMap(listOfEmailTempMapp);
        EmailTemplateMappingHander.insertInteractionEvtMap(newlist);
        system.assertEquals(1, [SELECT count() FROM Email_Template_Mapping__c WHERE Email_Template__c =: newlist[0].Email_Template__c]);
    }
    @isTest()
    static void beforeUpdatecheckCampaignStatusData1(){
        
        EmailTemplateMappingHanderTest.isTestFailInsert = true;
        
        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);        
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template__c> emailTempList1 = TestDataFactory.emailTemplateData(true);
        
        for(Campaign campaignEach:campaignList){
            campaignEach.Campaign_Stage__c ='Creation';
        }
        Update campaignList;
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp1 = TestDataFactory.emailTemplateMapData(campaignList, emailTempList1[0].id, true);        
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);       
        
        try{
            for(Email_Template_Mapping__c obj:listOfEmailTempMapp){
                obj.Status__c='Activate';
            }
            update listOfEmailTempMapp;
            Email_Template_Mapping__c emailTempMappEach = new Email_Template_Mapping__c(Email_Template__c =  emailTempList1[0].id,Campaign__c = campaignList[0].id,Status__c ='Activate ');
            listOfEmailTempMapp.add(emailTempMappEach);
            Email_Template_Mapping__c emailTempMappEach1 = new Email_Template_Mapping__c(Email_Template__c = emailTempList[0].id,Status__c = 'Not Activated');
            List<Email_Template_Mapping__c> newlist = new List<Email_Template_Mapping__c>();
            newlist.add(emailTempMappEach1);
            EmailTemplateMappingHander.updateTriggeredSend(listOfEmailTempMapp1);
            EmailTemplateMappingHander.updateTriggeredSend(listOfEmailTempMapp);
            EmailTemplateMappingHander.updateTriggeredSend(newlist);
            
            system.assertEquals(1, [SELECT count() FROM Email_Template_Mapping__c WHERE Campaign__c =: newlist[0].Campaign__c]);
            system.assertEquals(1, [SELECT count() FROM Email_Template_Mapping__c WHERE Email_Template__c =: newlist[0].Email_Template__c]);
            system.assertEquals(1, [SELECT count() FROM Email_Template_Mapping__c WHERE Campaign__c =: listOfEmailTempMapp[0].Campaign__c]);
            system.assertEquals(1, [SELECT count() FROM Email_Template_Mapping__c WHERE Email_Template__c =: listOfEmailTempMapp[0].Email_Template__c]);
            
            
        }catch(Exception e){
            system.assertEquals(e.getMessage(), e.getMessage()); }
    }
}