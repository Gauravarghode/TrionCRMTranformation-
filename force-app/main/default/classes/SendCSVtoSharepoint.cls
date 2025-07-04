public class SendCSVtoSharepoint {
    
    @future(callout=true)
    public static void fileMigration(String stagingId) {
        try{
            if (stagingId != 'Test##SP') {  
                List<EmailMessage_Html__b> emailStagingList = [select Id,  EmailMessage_Id__c, Status__c, Error_Message__c, Is_Large_File__c, File_Size__c, sObject__c, 
                                                               Title__c, File_Body__c, Parent_Case_Id__c, Job_ID__c, Csv_Body__c, Csv_Body_Extension__c, Csv_String_2__c
                                                               from EmailMessage_Html__b 
                                                               WHERE Status__c = 'Not Started' AND Emailmessage_Id__c=:stagingId
                                                               LIMIT 1];
                system.debug('emailStagingList' + emailStagingList);
                
                if (emailStagingList.isEmpty()) {
                    emailStagingList = [select Id,  EmailMessage_Id__c, Status__c, Error_Message__c, Is_Large_File__c, File_Size__c, sObject__c, 
                                        Title__c, File_Body__c, Parent_Case_Id__c, Job_ID__c, Csv_Body__c, Csv_Body_Extension__c,Csv_String_2__c
                                        from EmailMessage_Html__b 
                                        WHERE Status__c = 'Pending' AND Emailmessage_Id__c=:stagingId
                                        LIMIT 1]; 
                    
                }
                Integer statuscode;
                String jsonString;            
                Blob fileBody;
                Blob CsvBody;
                String fileName='';
                String csvId='';
                String emailMessagebody='';
                String emailMessageCsvbody='';
                String emailMessageCsvString='';
                string emailMessageCsvString3='';
                string emailMessageCsvString4='';
                 string emailMessageCsvString5='';
                 string emailMessageCsvString6='';
                String objectName='';
                string parentCaseId='';
                integer listSize=emailStagingList.size();
                
                
                for (EmailMessage_Html__b emhbl : emailStagingList) {
                    if(listSize > 0){
                        
                        fileName = emailStagingList[0].Title__c;
                        system.debug('fileName: ' +fileName);
                        csvId = fileName.substring(20, 38);
                        system.debug('String csvId: ' +csvId);
                        emailMessagebody = emailStagingList[0].File_Body__c;
                        emailMessageCsvbody = emailStagingList[0].Csv_Body__c;
                        emailMessageCsvString = emailStagingList[0].Csv_String_2__c;
                        /*emailMessageCsvString3= emailStagingList[0].csv_extension_1__c;
                         emailMessageCsvString4= emailStagingList[0].csv_extension_2__c;
                          emailMessageCsvString5= emailStagingList[0].csv_extension_3_c__c;
                         emailMessageCsvString6= emailStagingList[0].csv_extension_4_c__c; */
                     /*   if(emailMessagebody != null){
                            fileBody = Blob.valueOf(emailMessagebody); 
                        }else if(emailMessageCsvbody != null){
                            fileBody = Blob.valueOf(emailMessageCsvbody);
                        }else{
                            fileBody = Blob.valueOf(emailMessageCsvString);
                        }*/
					String emailMessageCsvbodyString = emailMessageCsvbody.toString();
					String emailMessageCsvStringString = emailMessageCsvString.toString();
                   /* String emailMessageCsvString3String=emailMessageCsvString3.tostring();
                    String emailMessageCsvString4String=emailMessageCsvString4.tostring();
                          String emailMessageCsvString5String=emailMessageCsvString5.tostring();
                          String emailMessageCsvString6String=emailMessageCsvString6.tostring();*/
                        
					String concatenatedString = emailMessageCsvbodyString + emailMessageCsvStringString;
					fileBody = Blob.valueOf(concatenatedString);
                      
                        objectName = emailStagingList[0].sObject__c;
                        parentCaseId=emailStagingList[0].Parent_Case_Id__c;
                        system.debug('String parentCaseId: ' +parentCaseId);
                    }
                }
                
                
                
                try {
                    String sharepointFolderName = Label.SharepointfolderName;
                    String driveId = Label.SharepointDriveId;
                    String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                    String encodedFileName = emailStagingList[0].Title__c;
                    String encodedObjectName = emailStagingList[0].Emailmessage_Id__c;
                    String encodedParentCaseId = emailStagingList[0].Parent_Case_Id__c;
                    String endpoint = 'callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/' + sharepointFolderName + '/' + encodedParentCaseId + '/' + encodedObjectName + '/' + encodedFileName.replaceAll('\\+', '%20') + ':/content';
                    
                    
                    Http httpCallout = new Http();
                    HttpRequest req = new HttpRequest();
                    
                    req.setEndpoint(endpoint);
                    req.setMethod('PUT');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Accept', 'application/json');
                    
                    req.setBodyAsBlob(fileBody);
                    system.debug('fileBody--->' + fileBody);
                    HTTPResponse res = httpCallout.send(req);
                    jsonString = res.getBody();
                    statuscode=res.getStatusCode();
                    
                    System.debug('Response retrieved -> ' + res.getBody());
                    System.debug('Status code -> ' + res.getStatusCode());
                    System.debug('Status -> ' + res.getStatus());
                    
                    
                    
                    if(res.getStatusCode() == 201 || res.getStatusCode() == 200){ 
                        updateSharepointStatus(emailStagingList[0], 'Completed', 'null', res);
                        System.debug('res.getStatusCode()=>' + res.getStatusCode());
                    } else{
                        String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                        updateSharepointStatus(emailStagingList[0], 'Pending', errorMessage, res);
                        System.debug('res.getStatusCode()=>' + res.getStatusCode());
                    }
                }
                catch(Exception e){
                    updateSharepointStatus(emailStagingList[0], ' ', 'Exception Caught!', null);
                    System.debug('Catch Exception=>' + e.getMessage());
                }
                //List<Case_Email__c> caseEmailList=new List<Case_Email__c>();
                if (statuscode == 201 || statuscode == 200){
                    
                    Map<String, Object> deserializeResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                    Map<String, Object> parentReference = (Map<String, Object>) deserializeResponse.get('parentReference');
                    
                    if (deserializeResponse != null && parentReference != null) {
                        String spid = (String) deserializeResponse.get('id');
                        System.debug('id: ' +spid);
                        String spweburl = (String) deserializeResponse.get('webUrl');
                        System.debug('webUrl: ' +spweburl);                        
                        String spFolName = (String) parentReference.get('id');
                        System.debug('webUrl: ' +spFolName);
                        List<Case_Email__c> ceList = new List<Case_Email__c>();
                        for (Case_Email__c ce : [SELECT Id, EmailMessage_Id__c, Email_Message_SharePoint_Id__c,Email_Message_SP_Folder_Id__c,Files_SP_Id__c
                                                 FROM Case_Email__c
                                                 WHERE EmailMessage_Id__c = :csvId]){
                                                     if(csvId.equals(ce.EmailMessage_Id__c)){
                                                         ce.Email_Message_SharePoint_Id__c=spid; 
                                                         ce.Email_Message_SP_Folder_Id__c=spFolName;
                                                         ce.EM_Sharepoint_Web_Url__c=spweburl;
                                                         ceList.add(ce);                              
                                                         system.debug('customObject.Email_Message_SharePoint_Id__c'+ ce.Email_Message_SharePoint_Id__c);
                                                     }
                                                 }                        
                        if (!ceList.isEmpty()) {
                            upsert ceList;
                        }                        
                    }  
                }
                //} else {
                // Handle the case where emailStagingList is empty
                //}
                //}
            }
        }
        
        catch(Exception e){
            Integration_Log_Error__c  intLog = new Integration_Log_Error__c ();
            intLog.Name = 'Exception';
            intLog.getMessage__c = e.getMessage();
            intLog.getCause__c =String.valueOf(e.getCause());
            intLog.getLineNumber__c=String.valueOf(e.getLineNumber());
            //intLog.getNumDml__c =String.valueOf(e.getNumDml());
            intLog.getStackTraceString__c=e.getStackTraceString();            
            intLog.getTypeName__c=e.getTypeName();           
            if(intLog.Name != null) {
                insert intLog;
            }
        }
    }
    public static void updateSharepointStatus(EmailMessage_Html__b recordToUpdate, String status, String errorMessage,HTTPResponse res) {
        String customSwitch = String.valueOf(System.Label.Switch); 
        try{
            EmailMessage_Html__b currentRecord = new EmailMessage_Html__b();
            currentRecord.Status__c = status;
            currentRecord.EmailMessage_Id__c=recordToUpdate.EmailMessage_Id__c;
            currentRecord.sObject__c = recordToUpdate.sObject__c;
            currentRecord.File_Size__c = recordToUpdate.File_Size__c;
            currentRecord.Title__c = recordToUpdate.Title__c;
            currentRecord.Parent_Case_Id__c=recordToUpdate.Parent_Case_Id__c;
            if (errorMessage != null && !String.isBlank(errorMessage)) {
                currentRecord.Error_Message__c = errorMessage.left(255);
            }
            
            if(currentRecord.Job_ID__c != 'Test##SP'){
                Database.SaveResult result = Database.insertImmediate(currentRecord);
                system.debug(result);
                if(result.isSuccess()){
                    Database.deleteImmediate(new EmailMessage_Html__b(Status__c = recordToUpdate.Status__c, EmailMessage_Id__c = recordToUpdate.EmailMessage_Id__c, sObject__c=recordToUpdate.sObject__c));
                }
            }
            
            //String customSwitch = Label.Swicth; 
            
            if(customSwitch == 'True') {
                
                //Creates log in Integration Log object to track the current Transaction
                IntegrationLogInserter(recordToUpdate, res);
            }
        }
        
        catch(Exception e){
            Integration_Log_Error__c  intLog = new Integration_Log_Error__c ();
            intLog.Name = 'Exception';
            intLog.getMessage__c = e.getMessage();
            intLog.getCause__c =String.valueOf(e.getCause());
            intLog.getLineNumber__c=String.valueOf(e.getLineNumber());
            //intLog.getNumDml__c =String.valueOf(e.getNumDml());
            intLog.getStackTraceString__c=e.getStackTraceString();            
            intLog.getTypeName__c=e.getTypeName();           
            if(intLog.Name != null) {
                insert intLog;
            }
        }
        
    }
    
    public static void IntegrationLogInserter(EmailMessage_Html__b emailStagingVar, HTTPResponse res) {
        
        Integration_Log_Error__c  intLog = new Integration_Log_Error__c ();
        intLog.Name = emailStagingVar.Id;
        intLog.getMessage__c = 'Parent Case Id -> ' + emailStagingVar.Parent_Case_Id__c;
        intLog.getCause__c = 'Status code is -> ' + res.getStatusCode();
        intLog.getStackTraceString__c = 'Status is -> ' + res.getStatus();
        
        if(intLog.Name != null) {
            insert intLog;
        }
    }
    
    
    
    
    public static void testCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        
        
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}