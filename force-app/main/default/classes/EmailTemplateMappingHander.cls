public class EmailTemplateMappingHander {

    public class CustomException extends exception {}

    public static void updateTriggeredSend(List<Email_Template_Mapping__c> listOfEmailTemplateMappingInserted){
        
        Set<Id> setOfCampaignIds = new Set<Id>();
        Set<Id> setOfEmailTemplateIds = new Set<Id>();
        List<et4ae5__Automated_Send__c> triggeredSendsToUpdate = new List<et4ae5__Automated_Send__c>();
        for(Email_Template_Mapping__c eachEmailTemplateMapping : listOfEmailTemplateMappingInserted){
            setOfCampaignIds.add(eachEmailTemplateMapping.Campaign__c);
            setOfEmailTemplateIds.add(eachEmailTemplateMapping.Email_Template__c);
        }
        system.debug(setOfEmailTemplateIds);
        Map<Id, Campaign> mapOfCampaignWithEmailMapping = New Map<Id, Campaign>([SELECT Id, Name, Campaign_Stage__c, (SELECT Id, Status__c FROM Email_Template_Mappings__r WHERE Status__c='Activate') FROM Campaign WHERE Id IN: setOfCampaignIds]);
        Map<Id, Email_Template__c> mapOfEmailTemplates = New Map<Id, Email_Template__c>([SELECT Id, Name, Email_Template_Id__c, Email_Asset_Id__c FROM Email_Template__c WHERE Id IN: setOfEmailTemplateIds]); 
        Map<Id, et4ae5__Automated_Send__c> mapOfCampaignIdAndTriggeredSend = new Map<Id, et4ae5__Automated_Send__c>();
        for(et4ae5__Automated_Send__c eachTriggeredSend : [SELECT Id, et4ae5__EmailAssetId__c, et4ae5__EmailId__c, et4ae5__EmailName__c, Campaign__c, Campaign__r.Id FROM et4ae5__Automated_Send__c WHERE Campaign__r.Id IN: setOfCampaignIds]){
            mapOfCampaignIdAndTriggeredSend.put(eachTriggeredSend.Campaign__r.Id, eachTriggeredSend);
        }
        for(Email_Template_Mapping__c eachEmailTemplateMapping : listOfEmailTemplateMappingInserted){
            if(!string.isEmpty(eachEmailTemplateMapping.Status__c) && eachEmailTemplateMapping.Status__c == 'Activate' && mapOfCampaignWithEmailMapping.get(eachEmailTemplateMapping.Campaign__c).Email_Template_Mappings__r.size() > 1){
                eachEmailTemplateMapping.addError('Already an email template is in \'Activate\' condition.');
            } else if(mapOfCampaignWithEmailMapping.get(eachEmailTemplateMapping.Campaign__c).Campaign_Stage__c != 'Email Template Selection'){
                //eachEmailTemplateMapping.addError('Campaign: '+ mapOfCampaignWithEmailMapping.get(eachEmailTemplateMapping.Campaign__c).Name + ' is not set to the Campaign Stage \'Email Template Selection\'.');
            }else if( eachEmailTemplateMapping.Status__c == 'Activate' && mapOfCampaignIdAndTriggeredSend.ContainsKey(eachEmailTemplateMapping.Campaign__c)){
                system.debug('eachEmailTemplateMapping.Id is '+eachEmailTemplateMapping.Id);
                et4ae5__Automated_Send__c eachTriggeredSend = mapOfCampaignIdAndTriggeredSend.get(eachEmailTemplateMapping.Campaign__c);
                system.debug(system.JSON.serializePretty(eachTriggeredSend));
                system.debug(system.JSON.serializePretty(mapOfEmailTemplates.get(eachEmailTemplateMapping.Email_Template__c)));
                eachTriggeredSend.et4ae5__EmailId__c = mapOfEmailTemplates.get(eachEmailTemplateMapping.Email_Template__c).Email_Asset_Id__c;
                eachTriggeredSend.et4ae5__EmailAssetId__c = mapOfEmailTemplates.get(eachEmailTemplateMapping.Email_Template__c).Email_Template_Id__c;
                eachTriggeredSend.et4ae5__EmailName__c = mapOfEmailTemplates.get(eachEmailTemplateMapping.Email_Template__c).Name;
            }
        }
        try{
            update mapOfCampaignIdAndTriggeredSend.values();
            if(EmailTemplateMappingHanderTest.isTestFailInsert){
                throw new CustomException('Fail the test class!');
            }
        } catch(exception e){
            system.debug('Exception is '+e.getMessage());
            //Declare the List to hold the Error_Login__c
            List<Error_Login__c> listOfErrorLogin = new List<Error_Login__c>();
            Error_Login__c eachErrorlogin = new Error_Login__c();
            eachErrorlogin.Error_LineNumber__c = e.getLineNumber();
            eachErrorlogin.Error_Message__c = e.getMessage();
            eachErrorlogin.Error_StackTraceString__c = e.getStackTraceString();
            eachErrorlogin.Error_TypeName__c = e.getTypeName();
            eachErrorlogin.Error_Cause__c	= string.valueof(e.getCause());
            listOfErrorLogin.add(eachErrorlogin);
            
            insert listOfErrorLogin;
            
        }
    }
    /*
* Insert Interaction_event_mapping__c when the EMailTemplateMapping is Cretaed
*/
   public static void insertInteractionEvtMap(List<Email_Template_Mapping__c> emailTempMapList){
        
        Map<string, string> emailTempCampaign = new Map<string, string>();
        for(Email_Template_Mapping__c emailTempObj : emailTempMapList){
            emailTempCampaign.put(emailTempObj.Email_Template__c, emailTempObj.Campaign__c);
        }
        List<Call_To_Action__c> listOfCallToAction = [SELECT id,Name, CTA_URL__c,Email_Template__c FROM Call_To_Action__c where Email_Template__c IN: emailTempCampaign.keySet()];
        List<Interaction_event_mapping__c> listOfInteractionEveMapping = new List<Interaction_event_mapping__c>();
        
        for(Call_To_Action__c callToActionObj:listOfCallToAction) {
            Interaction_event_mapping__c InteractionEveMappingVar = new Interaction_event_mapping__c();
            InteractionEveMappingVar.Action_Name__c = callToActionObj.Name;
            InteractionEveMappingVar.URL__c = callToActionObj.CTA_URL__c;
            InteractionEveMappingVar.Campaign__c= emailTempCampaign.get(callToActionObj.Email_Template__c);
            InteractionEveMappingVar.Email_Template__c = callToActionObj.Email_Template__c;
            listOfInteractionEveMapping.add(InteractionEveMappingVar);
        }
        try{
            insert listOfInteractionEveMapping;
        }
        catch(Exception e){
            system.debug('exception e is '+e.getMessage());
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(),
                Error_Cause__c = String.valueOf(e.getCause())
            );
        }
        
        
    }
    /*
* Update the Interaction Event Mapping when the Email_Template_Mapping__c Email Template changes
*/
   /* Public static void updateInteractionEvtMap(List<Email_Template_Mapping__c> newemailTempMapList, Map<id,Email_Template_Mapping__c> OldMapemailTempMap)
    {
        Set<id> emailTemplateids = new Set<id>();
        set<id> campaignids = new Set<id>();
        Map<string, string> emailTempCampaign = new Map<string, string>();
        for(Email_Template_Mapping__c emailTempObj : newemailTempMapList){
            
            if(OldMapemailTempMap.get(emailTempObj.id).Email_Template__c != emailTempObj.Email_Template__c ){
                emailTemplateids.add(OldMapemailTempMap.get(emailTempObj.id).Email_Template__c); 
                emailTempCampaign.put(emailTempObj.Email_Template__c,emailTempObj.Campaign__c);
            }
        }
        
        // Declare a List to hold the Call_To_Action__c
        List<Call_To_Action__c> listOfCallToAction = new List<Call_To_Action__c>();
        
        if(!emailTempCampaign.isEmpty()){   
            listOfCallToAction =[SELECT id,Name, CTA_URL__c,Email_Template__c FROM Call_To_Action__c where Email_Template__c IN: emailTempCampaign.keySet()];
        }
        
        List<Interaction_event_mapping__c> listOfInteractionEveMapToDelete = [SELECT id,Campaign__c,Email_Template__c FROM Interaction_event_mapping__c Where Email_Template__c IN:emailTemplateids];
        
        delete listOfInteractionEveMapToDelete;
        //Declare a list to hold the Interaction_event_mapping__c
        List<Interaction_event_mapping__c> listOfInteractionEveMapping = new List<Interaction_event_mapping__c>();
        //Iterate the listOfCallToAction if the emailTemplate Changes and insert the new Interaction_event_mapping__c
        for(Call_To_Action__c callToActionObj : listOfCallToAction) {   
            Interaction_event_mapping__c InteractionEveMappingVar = new Interaction_event_mapping__c();
            InteractionEveMappingVar.Action_Name__c = callToActionObj.Name;
            InteractionEveMappingVar.URL__c = callToActionObj.CTA_URL__c;
            InteractionEveMappingVar.Campaign__c = emailTempCampaign.get(callToActionObj.Email_Template__c);
            InteractionEveMappingVar.Email_Template__c = callToActionObj.Email_Template__c;
            
            listOfInteractionEveMapping.add(InteractionEveMappingVar);
        }
        try{
            if( !listOfInteractionEveMapping.isEmpty() ){   
                insert listOfInteractionEveMapping;
            }
            //if(!listOfInteractionEveMapToDelete.isEmpty()){
            // delete listOfInteractionEveMapToDelete; }
        }
        catch(Exception e){
            //Declare the List to hold the Error_Login__c
            Error_Login__c eachErrorlogin = new Error_Login__c();
            eachErrorlogin.Error_LineNumber__c = e.getLineNumber();
            eachErrorlogin.Error_Message__c = e.getMessage();
            eachErrorlogin.Error_StackTraceString__c = e.getStackTraceString();
            eachErrorlogin.Error_TypeName__c = e.getTypeName();
            eachErrorlogin.Error_Cause__c	= string.valueof(e.getCause());
            insert eachErrorlogin;
        }
    }*/
    /*
* Check the status of the Campaign before inserting or Updating the Email_Template_Mapping__c
*/
    public static void beforeInsertcheckCampaignStatus(List<Email_Template_Mapping__c> newemailTempMapList)
    {  
        Set<id> campaignids = new Set<id>();
        
        for(Email_Template_Mapping__c eachEmailTemplateMap :newemailTempMapList){
            campaignids.add(eachEmailTemplateMap.Campaign__c);
        }
        Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>([SELECT Id, Campaign_Stage__c FROM Campaign WHERE Id IN: campaignids]);
        for(Email_Template_Mapping__c emailTemplateMapEach :newemailTempMapList){
            if(mapOfCampaigns.get(emailTemplateMapEach.Campaign__c).Campaign_Stage__c != 'Template Tagging'){
                emailTemplateMapEach.addError('Attention: Field Restricted. The Email template mapping cannot be created at the ' + mapOfCampaigns.get(emailTemplateMapEach.Campaign__c).Campaign_Stage__c + ' stage. Kindly advance to the "Template Tagging" stage for population');
            }
        }
        
    }
    
    /*
* Check the status of the Campaign before inserting or Updating the Email_Template_Mapping__c
*/
    public static void beforeUpdatecheckCampaignStatus(List<Email_Template_Mapping__c> newemailTempMapList, Map<Id, Email_Template_Mapping__c> oldEmailTempMap) {  
        Set<id> campaignids = new Set<id>();
        //Stamp the timing when the template mapping is changed to Activate
        for(Email_Template_Mapping__c eachEmailTemplateMap : newemailTempMapList){
            if(eachEmailTemplateMap.Status__c == 'Activate' && oldEmailTempMap.get(eachEmailTemplateMap.Id).Status__c != 'Activate'){
                eachEmailTemplateMap.Template_Last_Activated_On__c = system.now();
            }
            campaignids.add(eachEmailTemplateMap.Campaign__c);
        }
        Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>([SELECT Id, Campaign_Stage__c FROM Campaign WHERE Id IN: campaignids]);
        for(Email_Template_Mapping__c emailTemplateMapEach :newemailTempMapList)
        {
            if(emailTemplateMapEach.Status__c != oldEmailTempMap.get(emailTemplateMapEach.Id).Status__c && mapOfCampaigns.get(emailTemplateMapEach.Campaign__c).Campaign_Stage__c != 'Email Template Selection'){
                emailTemplateMapEach.addError('Attention: Field Restricted. The Status cannot be filled/edited at the ' + mapOfCampaigns.get(emailTemplateMapEach.Campaign__c).Campaign_Stage__c + ' stage. Kindly advance to the "	Email Template Selection" stage for population');
            }else if(emailTemplateMapEach.Status__c == oldEmailTempMap.get(emailTemplateMapEach.Id).Status__c && mapOfCampaigns.get(emailTemplateMapEach.Campaign__c).Campaign_Stage__c != 'Template Tagging'){
                //emailTemplateMapEach.addError('Campaign stage should be set to "Templates Administration" when  updating Template Mapping');
            }
        }
        
    }
    Public static void checkDuplicatesforEmailTEmplate(List<Email_Template_Mapping__c> newEmailTempMapList){
        
        Map<string,Email_Template_Mapping__c> mapOfEmailTempMap = new Map<string,Email_Template_Mapping__c>();
        List<Email_Template_Mapping__c> listOfEmailTempMapping = [SELECT id,Name,Campaign__c,Email_Template__c FROM Email_Template_Mapping__c];
        for(Email_Template_Mapping__c Obj: listOfEmailTempMapping){
          string emailTempCampaignCombination =Obj.Email_Template__c+'|'+Obj.Campaign__c;
           mapOfEmailTempMap.put(emailTempCampaignCombination,Obj);
        }
        for(Email_Template_Mapping__c eachEmailTempMapp: newEmailTempMapList){
            
            string emailTempCampaign =eachEmailTempMapp.Email_Template__c+'|'+eachEmailTempMapp.Campaign__c;
            
            if(mapOfEmailTempMap.containsKey(emailTempCampaign)){
                eachEmailTempMapp.addError('Action Failed! Duplicate Email Template Mapping is found(with same Campaign and Email Template)');
            }
            
        }
    }

}