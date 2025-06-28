public class CallToActionHandler {
    /*
* Create InteractionEventMapping when Call To Action is Created
*/
    public class CustomException extends exception {}
    Public static void insertInteractionEventMap(List<Call_To_Action__c> newCallToActionList){
        
        // set<id> emailTemplateIds = new set<id>();
        // Declare a Map to hold the emailTemplate as key and CallTo Action as Value
        Map<string,Call_To_Action__c> mapOfCallToAction = new Map<string,Call_To_Action__c>();
        for(Call_To_Action__c eachCallToAction: newCallToActionList){
            // emailTemplateIds.add(eachCallToAction.Email_Template__c);
            mapOfCallToAction.put(eachCallToAction.Email_Template__c,eachCallToAction);
        }
        //query the Email_Template_Mapping__c based on the mapOfCallToAction keyset
        List<Email_Template_Mapping__c> listOfEmailTemplateMap = [SELECT id,Name, Email_Template__c,Campaign__c FROM Email_Template_Mapping__c WHERE Email_Template__c IN:mapOfCallToAction.keySet()];
        
        //Declare a Map tp hold the EmailTemplate as key and 
        Map<string,Set<string>> emailTempCampaignMap = new Map<string,Set<string>>();
        for(Email_Template_Mapping__c emailTempMapEach:listOfEmailTemplateMap ){
            if(emailTempCampaignMap.containsKey(emailTempMapEach.Email_Template__c)){
                emailTempCampaignMap.get(emailTempMapEach.Email_Template__c).add(emailTempMapEach.Campaign__c);
                
            } else{
                emailTempCampaignMap.put(emailTempMapEach.Email_Template__c, new Set<String>{emailTempMapEach.Campaign__c});
                
            }
        }
        //Declare a list to the Interaction Event Mapping
        List<Interaction_event_mapping__c> listOfInteractionEventMap = new List<Interaction_event_mapping__c>();
        for(string  emailTemCampaignEach: emailTempCampaignMap.keySet()){
            Set<string> campaignSets =emailTempCampaignMap.get(emailTemCampaignEach);
            for(string campaignEach:campaignSets){
                Interaction_event_mapping__c InteractionEveMappingVar = new Interaction_event_mapping__c();
                InteractionEveMappingVar.Action_Name__c = mapOfCallToAction.get(emailTemCampaignEach).Name;
                InteractionEveMappingVar.URL__c = mapOfCallToAction.get(emailTemCampaignEach).CTA_URL__c;
                InteractionEveMappingVar.Campaign__c= campaignEach;
                InteractionEveMappingVar.Email_Template__c = emailTemCampaignEach;
                listOfInteractionEventMap.add(InteractionEveMappingVar);
            }
            
        }
        try{
            insert listOfInteractionEventMap;
            if(CallToActionHandlerTest.isTestFailInsert){
                throw new CustomException('Fail the test class!');
            }
        }catch(Exception e){
            system.debug('exception e is '+e.getMessage());
            insert new Error_Login__c(Error_LineNumber__c = e.getLineNumber(), Error_Message__c = e.getMessage(), Error_StackTraceString__c = e.getStackTraceString(), Error_TypeName__c = e.getTypeName(),  Error_Cause__c = String.valueOf(e.getCause()));
        }
    }
}