/*
* Author: Rahul Allada (EA)
* Date: 08th May 2023
*/

public class McApiIntegration {
    
    public class customException extends exception{}
    @AuraEnabled
    Public static void createEmailTemplatesAndCtas(){
        
        string accessToken = getAccessToken();
        getEmailTemplates(accessToken);
    }
    
    Public static String getAccessToken(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://mcq5z7xhd1lhblf7k4134--45-s4.auth.marketingcloudapis.com/v2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '172');
        req.setTimeout(120000);
        
        String requestBody = '{"grant_type": "client_credentials", "client_id": "9gct47qaz5vl4tqicmsnr0h4", "client_secret": "H9tzwUJebvbNj4kfSEV0HIDJ", "account_id": "546000953"}';
        req.setBody(requestBody);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            // Do something with the deserialized tokenResponse object
            system.debug(res.getBody());
            return tokenResponse.access_token;
        } else {
            return null;
            // Handle the error response
        }
    }
    
    Public static void getEmailTemplates(string accessToken){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://mcq5z7xhd1lhblf7k4134--45-s4.rest.marketingcloudapis.com/asset/v1/content/assets/query');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer '+accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"query": {"property": "assetType.id","simpleOperator": "equals","valueType": "int","value": 208}}');
        HttpResponse response = http.send(request);
        System.debug('>>> response ' + system.JSON.serializePretty(response.getBody()));
        System.debug('response is '+response);
        List<Call_To_Action__c> listOfCallToAction1=[SELECT id, Name,CTA_URL__c, Email_Template__r.Email_Template_Id__c, Email_Template__c FROM Call_To_Action__c ];
        
        Map<string,Set<string>> allEmailTemplateLinks = new Map<string,Set<string>>();
        for(Call_To_Action__c eachEmailTempObj:listOfCallToAction1){
            if(allEmailTemplateLinks.containsKey(eachEmailTempObj.Email_Template__r.Email_Template_Id__c)){
                allEmailTemplateLinks.get(eachEmailTempObj.Email_Template__r.Email_Template_Id__c).add(eachEmailTempObj.CTA_URL__c);
            } else{
                allEmailTemplateLinks.put(eachEmailTempObj.Email_Template__r.Email_Template_Id__c, new Set<String>{eachEmailTempObj.CTA_URL__c});
            }
            
        }
        List<Email_Template__c> listOfEmailTemplatesToInsert = new List<Email_Template__c>(); //= [SELECT Id, Name, Email_Template_Id__c FROM Email_Template__c];
        List<Email_Template__c> listOfEmailTemplatesToUpdate = new List<Email_Template__c>();
        Map<String, Email_Template__c> mapOfTemplateIdAndTemplates = new Map<String, Email_Template__c>();
        Map<string,set<string>> emailTemplateLinksMap = new Map<string,set<string>>();//
        Map<string,set<string>> emailTempCallToActionLinks = new Map<string,set<string>>();
        List<Call_To_Action__c> listOfCallToAction = new List<Call_To_Action__c>();
        for(Email_Template__c eachEmailTemplate : [SELECT Id, Name, Email_Template_Id__c FROM Email_Template__c]){
            mapOfTemplateIdAndTemplates.put(eachEmailTemplate.Email_Template_Id__c, eachEmailTemplate);
        }
        if (response.getStatusCode() == 200) {
            system.debug('response.getBody()=='+response.getBody());
            emailTemplateWrapper emailResponse = (emailTemplateWrapper) JSON.deserialize(response.getBody(), emailTemplateWrapper.class);
            system.debug('emailResponse is '+emailResponse.items.size());
            //system.debug('emailResponse is '+emailResponse);
            List<string> htmlcontents = new List<string>();
            for(cls_items eachItem : emailResponse.items){
                system.debug(eachItem.views.html.content);
                                system.debug(eachItem.name);
                Pattern anchors = Pattern.compile('<a.+?href="([^"]+?)"');
                Matcher m = anchors.matcher(eachItem.views.html.content);
                while (m.find()){
                    string links = m.group().split('=')[1];
                    
                    if(emailTemplateLinksMap.containsKey(eachItem.Id)){
                        emailTemplateLinksMap.get(eachItem.Id).add(links.subStringBetween( '"', '"' ));
                    } else{
                        emailTemplateLinksMap.put(eachItem.Id, new Set<String>{links.subStringBetween( '"', '"' )});
                    }
                }
                system.debug(emailTemplateLinksMap.Size());
                /*Set<string> newEmailTempLink = emailTemplateLinksMap.get(eachItem.Id);
                //System.debug('newEmailTempLink----'+newEmailTempLink);
               //  Set<string> existingEmailTempLinks =allEmailTemplateLinks.get(eachItem.Id);
               //  System.debug('existingEmailTempLinks----'+existingEmailTempLinks);
                /*if(!existingEmailTempLinks.isEmpty()){
                for(string eachLink: existingEmailTempLinks) {
                    if(newEmailTempLink.contains(eachLink)&&eachLink!=null){
                        newEmailTempLink.remove(eachLink);
                    }
                    system.debug(newEmailTempLink);
                }}
                if(!newEmailTempLink.isEmpty()){
                    emailTempCallToActionLinks.put(eachItem.Id,newEmailTempLink);}*/
               // system.debug(eachItem.name);
                system.debug('mapOfTemplateIdAndTemplates is '+ system.json.serializePretty(mapOfTemplateIdAndTemplates));
                if(mapOfTemplateIdAndTemplates.isEmpty()){
                    system.debug('Inside');
                    listOfEmailTemplatesToInsert.add(new Email_Template__c(Name = eachItem.name, Email_Template_Id__c = eachItem.id, Email_Asset_Id__c = eachItem.legacyData.legacyId ));
                } else if(!mapOfTemplateIdAndTemplates.containsKey(eachItem.Id)){
                    system.debug('Inside');
                    listOfEmailTemplatesToInsert.add(new Email_Template__c(Name = eachItem.name, Email_Template_Id__c = eachItem.id, Email_Asset_Id__c = eachItem.legacyData.legacyId));
                }else if (mapOfTemplateIdAndTemplates.containsKey(eachItem.Id) && mapOfTemplateIdAndTemplates.get(eachItem.Id).Name != eachItem.name){
                    
                    system.debug('eachItem.Id is '+eachItem.Id);
                    system.debug('mapOfTemplateIdAndTemplates.get(eachItem.Id).Id is '+mapOfTemplateIdAndTemplates.get(eachItem.Id));
                    system.debug('mapOfTemplateIdAndTemplates.get(eachItem.Id).Id is '+mapOfTemplateIdAndTemplates.get(eachItem.Id).Id);
                    
                    listOfEmailTemplatesToUpdate.add(new Email_Template__c(Name = eachItem.name, Id = mapOfTemplateIdAndTemplates.get(eachItem.Id).Id, Email_Template_Id__c = eachItem.id, Email_Asset_Id__c = eachItem.legacyData.legacyId));
                    mapOfTemplateIdAndTemplates.remove(eachItem.Id);
                }else if (mapOfTemplateIdAndTemplates.containsKey(eachItem.Id) && mapOfTemplateIdAndTemplates.get(eachItem.Id).Name == eachItem.name){
                    
                    system.debug('eachItem.Id is '+eachItem.Id);
                    system.debug('mapOfTemplateIdAndTemplates.get(eachItem.Id).Id is '+mapOfTemplateIdAndTemplates.get(eachItem.Id));
                    system.debug('mapOfTemplateIdAndTemplates.get(eachItem.Id).Id is '+mapOfTemplateIdAndTemplates.get(eachItem.Id).Id);
                    
                    //listOfEmailTemplatesToUpdate.add(new Email_Template__c(Name = eachItem.name, Id = mapOfTemplateIdAndTemplates.get(eachItem.Id).Id, Email_Template_Id__c = eachItem.id, Email_Asset_Id__c = eachItem.legacyData.legacyId));
                    mapOfTemplateIdAndTemplates.remove(eachItem.Id);
                }
               // system.debug(emailTempCallToActionLinks);                
                
            }
            
            for(Email_Template__c eachEmailTemplate : mapOfTemplateIdAndTemplates.values()){
                eachEmailTemplate.Activated__c = false;
            }
            
                            //Set<string> newEmailTempLink = emailTemplateLinksMap.get(eachItem.Id);
                           // System.debug('newEmailTempLink----'+newEmailTempLink);

        } else {
            //return null;
            // Handle the error response
        }
      //  system.debug(emailTempCallToActionLinks);  
        try{
            insert listOfEmailTemplatesToInsert;
            system.debug(listOfEmailTemplatesToInsert);
            update listOfEmailTemplatesToUpdate;
            update mapOfTemplateIdAndTemplates.values();
            if(McApiIntegrationTest.throwException){
                throw new customException('Hey');
            }
            
        } Catch(exception e){
            system.debug(e.getMessage());
            System.debug('Exception is '+e.getMessage());
            insert new Error_Login__c(
                Error_LineNumber__c = e.getLineNumber(),
                Error_Message__c = e.getMessage(),
                Error_StackTraceString__c = e.getStackTraceString(),
                Error_TypeName__c = e.getTypeName(),
                Error_Cause__c = String.valueOf(e.getCause())
            );
            
        }
        
      List<Email_Template__c> listOfEmailTamp =[SELECT id,Name,Email_Template_Id__c FROM Email_Template__c];
        Map<string,string> mapofEamilTemp = new Map<string,string>();
        if(!listOfEmailTamp.isEmpty()){
        for(Email_Template__c emailTempEach:listOfEmailTamp){
            mapofEamilTemp.put(emailTempEach.Email_Template_Id__c,emailTempEach.id);
        }
        }
        set<String> finalSet = new set<string>();
        for(string Obj: emailTemplateLinksMap.keySet()){
            Set<string> abc =  emailTemplateLinksMap.get(Obj);
            if(allEmailTemplateLinks.containsKey(Obj)){
                // abc = emailTemplateLinksMap.get(Obj);
                Set<string> abc1 = allEmailTemplateLinks.get(Obj);
                for(string Obj1: abc1){
                    if(abc.contains(Obj1)){
                        abc.remove(Obj1);
                    }
                    }
                system.debug('abc----'+abc);
                if(!abc.isEMpty()){
                emailTempCallToActionLinks.put(Obj,abc);}
                }
            else{
                emailTempCallToActionLinks.put(Obj,abc);}
            }
             
        
        System.debug(emailTempCallToActionLinks);
        for(string emailTempCTSEach:emailTempCallToActionLinks.keyset())
        {   
            
            set<string> emailTempSetLinks = emailTempCallToActionLinks.get(emailTempCTSEach);
            for(string linkEach : emailTempSetLinks){
                Call_To_Action__c callToActionEach = new Call_To_Action__c();
                callToActionEach.CTA_URL__c = linkEach;
                callToActionEach.Email_Template__c = mapofEamilTemp.get(emailTempCTSEach);
                listOfCallToAction.add(callToActionEach);
            }
        }
        insert listOfCallToAction;
        
    }
    
    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
    }
    
    public class emailTemplateWrapper{
        public Integer count;	//7
        public Integer page;	//1
        public Integer pageSize;
        public string name;
        public string description;
        public cls_items[] items;
    }
    
    class cls_items{
        public String id;	//9968
        public String customerKey;	//dd1d26d9-57ed-4da9-b408-9826ceea296f
        public String objectID;	//99e6d039-14ee-49a6-8e5c-fdd87335531b
        public String contentType;
        public string name;
        public cls_views views;
        public cls_legacydata legacyData;
    }
    
    class cls_views{
        public cls_html html;
    }
    
    class cls_html {
        public String content;
    }
    
    class cls_legacydata{
        public string legacyId;
        public string legacyKey;
        public string legacyType;
        public string legacyCategoryId;
    } 
    
    
}