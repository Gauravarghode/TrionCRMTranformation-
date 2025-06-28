public with sharing class UpdateCampaignMembersQueuable implements Queueable {

    List<CampaignMember> listOfCampaignMembersToBeUpdated;

    public class CustomException extends Exception {}

    public UpdateCampaignMembersQueuable() {
        listOfCampaignMembersToBeUpdated = new List<CampaignMember>();
    }

    public UpdateCampaignMembersQueuable(List<CampaignMember> listOfCampaignMembers) {
        this();
        this.listOfCampaignMembersToBeUpdated = listOfCampaignMembers;
    }

    public void execute(QueueableContext context) {
        for (CampaignMember eachCampaignMember : listOfCampaignMembersToBeUpdated) {
            eachCampaignMember.Status__c = 'Activated / In Progress';
        }
        try {
            update listOfCampaignMembersToBeUpdated;
            if (CampaignTriggerHandlerTest.isTestFailInsert) {
                throw new CustomException('Fail the test class!');
            }
        } catch (Exception e) {
            System.debug('Exception e is ' + e.getMessage());

            List<Error_Login__c> listOfErrorLogin = new List<Error_Login__c>();
            Error_Login__c eachErrorlogin = new Error_Login__c();
            eachErrorlogin.Error_LineNumber__c = e.getLineNumber();
            eachErrorlogin.Error_Message__c = e.getMessage();
            eachErrorlogin.Error_StackTraceString__c = e.getStackTraceString();
            eachErrorlogin.Error_TypeName__c = e.getTypeName();
            eachErrorlogin.Error_Cause__c = String.valueOf(e.getCause());
            listOfErrorLogin.add(eachErrorlogin);

            insert listOfErrorLogin;
        }
    }
}