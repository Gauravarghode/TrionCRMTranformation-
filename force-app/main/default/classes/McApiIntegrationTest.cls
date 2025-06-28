@isTest()
public class McApiIntegrationTest {
    public static boolean throwException = false;
    
    @testSetup
    static void testData(){

        List<Campaign> campaignList = TestDataFactory.campaignTestData(true);
        List<Contact> listOfContact =TestDataFactory.contactData(true);
        List<CampaignMember> listOfCampaignMember = TestDataFactory.campaignMemberTestData(true,campaignList,listOfContact[0].id);   
        List<Email_Template__c> emailTempList = TestDataFactory.emailTemplateData(true);
        List<Email_Template_Mapping__c> listOfEmailTempMapp = TestDataFactory.emailTemplateMapData(campaignList, emailTempList[0].id, true);
        List<Call_To_Action__c> listOfCallToAction = TestDataFactory.callToActionTestData(true,emailTempList[0].id);
         TestDataFactory.callToActionTestData(true,emailTempList[0].id);
        List<Interaction_event_mapping__c> interactionEvtMapList =TestDataFactory.interactionEventMappingData(true,campaignList[0].id,listOfCallToAction);
        List<et4ae5__Automated_Send__c> listOfTriggerSend = TestDataFactory.triggerSendTestData(true,campaignList[0].id);
        List<et4ae5__IndividualEmailResult__c> individualEmailResList = TestDataFactory.individualemailResultsTestData1(false,campaignList[0].id,listOfContact[0].id,emailTempList,listOfTriggerSend[0].id,listOfCampaignMember[0].id);
    }
    
    private class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            if (req.getEndpoint().endsWith('token')) {
                HttpResponse res = new HttpResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                String requestBody = '{'+
                    '"access_token": "eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiIzOGMyY3BGMVNBOHlQUndwQzQzc1pXenkiLCJjbGllbnRfaWQiOiI5Z2N0NDdxYXo1dmw0dHFpY21zbnIwaDQiLCJlaWQiOjU0NjAwMDk1Mywic3RhY2tfa2V5IjoiUzEzIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciIsInBpZCI6NTI5fQ.qsBWhjk73exPd3AvTebrUYfz6HRZPfBuY5t7za9T4xE.j_QA-AJx0jjpIHXh961kUlO12DuJE_879FYp0cThZJb3u8ZB3-KjG7L-OzIGExInwYV-84KpgHz1xQSrSAF0B7ve6TzmInJwEryJi9jNNeBDAhA_Y3ETTTpKSxne99OxijN2JyrWQZ4SDeDGH_WkKJAjaEbwNaRKy5wCm",'+
                    '"token_type": "Bearer",'+
                    '"expires_in": 1079,'+
                    '"scope": "offline documents_and_images_read documents_and_images_write saved_content_read saved_content_write automations_execute automations_read automations_write journeys_execute journeys_read journeys_write email_read email_send email_write push_read push_send push_write sms_read sms_send sms_write social_post social_publish social_read social_write web_publish web_read web_write audiences_read audiences_write list_and_subscribers_read list_and_subscribers_write data_extensions_read data_extensions_write file_locations_read file_locations_write tracking_events_read webhooks_read webhooks_write approvals_write ott_chat_messaging_read ott_chat_messaging_send marketing_cloud_connect_read marketing_cloud_connect_write marketing_cloud_connect_send event_notification_callback_create event_notification_callback_read event_notification_callback_update event_notification_subscription_create tracking_events_write key_manage_view key_manage_rotate key_manage_revoke dfu_configure journeys_aspr journeys_delete market_audience_create market_audience_view market_audience_update market_audience_delete market_audience_member_create market_audience_member_view market_audience_member_update market_audience_member_delete contact_bu_mapping_create contact_bu_mapping_view contact_bu_mapping_update contact_bu_mapping_delete http_headers_view http_headers_update http_headers_delete",'+
                    '"soap_instance_url": "https://mcq5z7xhd1lhblf7k4134--45-s4.soap.marketingcloudapis.com/",'+
                    '"rest_instance_url": "https://mcq5z7xhd1lhblf7k4134--45-s4.rest.marketingcloudapis.com/"'+
                    '}';
                
                res.setBody(requestBody);
                
                return res;
            } else if (req.getEndpoint().endsWith('query')){
                HttpResponse res = new HttpResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                string link='www.google.com';
                String requestBody ='{'+

                    '"count": 11,'+
                    '"page": 1,'+
                    '"pageSize": 50,'+
                    '"links": {},'+
                    '"items": ['+
                    '{'+
                    '"id": 23456,'+
                    '"customerKey": "c28c730b-6049-482f-a01f-9e2ef6f9c309",'+
                    '"objectID": "8d3e1d47-59b2-4498-bdc8-d061e29a6057",'+
                    '"contentType": "application/vnd.etmc.email.Message; kind=paste",'+
                    '"assetType": {'+
                    '"id": 208,'+
                    '"name": "htmlemail",'+
                    '"displayName": "HTML Email"'+
                    '},'+
                    '"name": " Case SurveyTemplate",'+
                    '"description": "",'+
                    '"owner": {'+
                    '"id": 747096913,'+
                    '"email": "gangabhavani@enabledanalytics.com",'+
                    '"name": "Ganga Bhavani",'+
                    '"userId": "747096913"'+
                    '},'+
                    '"createdDate": "2023-06-14T01:00:48.017-06:00",'+
                    '"createdBy": {'+
                    '"id": 747096913,'+
                    '"email": "gangabhavani@enabledanalytics.com",'+
                    '"name": "Ganga Bhavani",'+
                    '"userId": "747096913"'+
                    '},'+
                    '"modifiedDate": "2023-07-07T02:47:47.097-06:00",'+
                    '"modifiedBy": {'+
                    '"id": 747096913,'+
                    '"email": "gangabhavani@enabledanalytics.com",'+
                    '"name": "Ganga Bhavani",'+
                    '"userId": "747096913"'+
                    '},'+
                    '"enterpriseId": 546000953,'+
                    '"memberId": 546000953,'+
                    '"status": {'+
                    '"id": 1,'+
                    '"name": "Draft"'+
                    '},'+
                    '"thumbnail": {'+
                    '"thumbnailUrl": "/v1/assets/14910/thumbnail"'+
                    '},'+
                    '"category": {'+
                    '"id": 23456'+
                    '},'+
                    '"views": {'+
                    '"subjectline": {'+
                    '"contentType": "application/vnd.etmc.email.View; kind=subjectline",'+
                    '"content": "Please Fill Our Survey!",'+
                    '"meta": {},'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"preheader": {'+
                    '"contentType": "application/vnd.etmc.email.View; kind=preheader",'+
                    '"content": "",'+
                    '"meta": {},'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"html": {'+
                    //'"content": "<a href=\\"www.google.com\\",'+
                      '"content": "<a href='+link+'/>",'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"amp": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"text": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": "html"'+
                    '}'+
                    '}'+
                    '},'+
                    '"generateFrom": "html",'+
                    '"modelVersion": 2'+
                    '},'+
                    '"viewAsAWebPage": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"subscriptioncenter": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"forwardHTML": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"forwardText": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '}'+
                    '},'+
                    '"availableViews": ['+
                    '"subjectline",'+
                    '"preheader",'+
                    '"html",'+
                    '"amp",'+
                    '"text",'+
                    '"viewAsAWebPage",'+
                    '"subscriptioncenter",'+
                    '"forwardHTML",'+
                    '"forwardText"'+
                    '],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"characterEncoding": "utf-8"'+
                    '},'+
                    '"legacy": {'+
                    '"legacyId": 3867,'+
                    '"legacyKey": "c28c730b-6049-482f-a01f-9e2ef6f9c309",'+
                    '"legacyType": "email",'+
                    '"legacyCategoryId": 25066'+
                    '}'+
                    '}'+
                    '},'+
                    '"legacyData": {'+
                    '"legacyId": 3867,'+
                    '"legacyKey": "c28c730b-6049-482f-a01f-9e2ef6f9c309",'+
                    '"legacyType": "email",'+
                    '"legacyCategoryId": 25066'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '{'+
                    '"id": 23456,'+
                    '"customerKey": "c28c730b-6049-482f-a01f-9e2ef6f9c309",'+
                    '"objectID": "8d3e1d47-59b2-4498-bdc8-d061e29a6057",'+
                    '"contentType": "application/vnd.etmc.email.Message; kind=paste",'+
                    '"assetType": {'+
                    '"id": 208,'+
                    '"name": "htmlemail",'+
                    '"displayName": "HTML Email"'+
                    '},'+
                    '"name": " Case SurveyTemplate",'+
                    '"description": "",'+
                    '"owner": {'+
                    '"id": 747096913,'+
                    '"email": "gangabhavani@enabledanalytics.com",'+
                    '"name": "Ganga Bhavani",'+
                    '"userId": "747096913"'+
                    '},'+
                    '"createdDate": "2023-06-14T01:00:48.017-06:00",'+
                    '"createdBy": {'+
                    '"id": 747096913,'+
                    '"email": "gangabhavani@enabledanalytics.com",'+
                    '"name": "Ganga Bhavani",'+
                    '"userId": "747096913"'+
                    '},'+
                    '"modifiedDate": "2023-07-07T02:47:47.097-06:00",'+
                    '"modifiedBy": {'+
                    '"id": 747096913,'+
                    '"email": "gangabhavani@enabledanalytics.com",'+
                    '"name": "Ganga Bhavani",'+
                    '"userId": "747096913"'+
                    '},'+
                    '"enterpriseId": 546000953,'+
                    '"memberId": 546000953,'+
                    '"status": {'+
                    '"id": 1,'+
                    '"name": "Draft"'+
                    '},'+
                    '"thumbnail": {'+
                    '"thumbnailUrl": "/v1/assets/14910/thumbnail"'+
                    '},'+
                    '"category": {'+
                    '"id": 23456'+
                    '},'+
                    '"views": {'+
                    '"subjectline": {'+
                    '"contentType": "application/vnd.etmc.email.View; kind=subjectline",'+
                    '"content": "Please Fill Our Survey!",'+
                    '"meta": {},'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"preheader": {'+
                    '"contentType": "application/vnd.etmc.email.View; kind=preheader",'+
                    '"content": "",'+
                    '"meta": {},'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"html": {'+
                    '"content": "Hello!",'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"amp": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"text": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": "html"'+
                    '}'+
                    '}'+
                    '},'+
                    '"generateFrom": "html",'+
                    '"modelVersion": 2'+
                    '},'+
                    '"viewAsAWebPage": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"subscriptioncenter": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"forwardHTML": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '},'+
                    '"forwardText": {'+
                    '"availableViews": [],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"generateFrom": ""'+
                    '}'+
                    '}'+
                    '},'+
                    '"modelVersion": 2'+
                    '}'+
                    '},'+
                    '"availableViews": ['+
                    '"subjectline",'+
                    '"preheader",'+
                    '"html",'+
                    '"amp",'+
                    '"text",'+
                    '"viewAsAWebPage",'+
                    '"subscriptioncenter",'+
                    '"forwardHTML",'+
                    '"forwardText"'+
                    '],'+
                    '"data": {'+
                    '"email": {'+
                    '"options": {'+
                    '"characterEncoding": "utf-8"'+
                    '},'+
                    '"legacy": {'+
                    '"legacyId": 3867,'+
                    '"legacyKey": "c28c730b-6049-482f-a01f-9e2ef6f9c309",'+
                    '"legacyType": "email",'+
                    '"legacyCategoryId": 25066'+
                    '}'+
                    '}'+
                    '},'+
                    '"legacyData": {'+
                    '"legacyId": 3867,'+
                    '"legacyKey": "c28c730b-6049-482f-a01f-9e2ef6f9c309",'+
                    '"legacyType": "email",'+
                    '"legacyCategoryId": 25066'+
                    '},'+
                    '"modelVersion": 2'+
                    '}' +
                    ']'+
                    '}';
                
                res.setBody(requestBody);
                
                return res;
            } else {
                return null;
            }
        }
    }
    
    @isTest
    static void getTokenTestClass(){
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        test.startTest();
        McApiIntegration.createEmailTemplatesAndCtas();
        McApiIntegration.TokenResponse tkn=new McApiIntegration.TokenResponse();
        tkn.expires_in=30;
        tkn.token_type='oauth';
        tkn.rest_instance_url='';
        tkn.soap_instance_url='';
        tkn.scope='access';
        test.stopTest();
    }
    
    @isTest
    static void throwException(){
        throwException = true;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        test.startTest();
        McApiIntegration.createEmailTemplatesAndCtas();
        test.stopTest();
    }
}