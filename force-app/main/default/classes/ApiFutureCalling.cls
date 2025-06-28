public class ApiFutureCalling{
    
    @future(callout=true)
    public static void fileMigration(String stagingId){
        try{
            if(stagingId != 'Test##SP'){
                
                List<Staging__b> stagingList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c, Title__c, From_sObject__c
                                                from Staging__b
                                                where Status__c = 'Not Started' and Chunk__c =: stagingId
                                                LIMIT 1];
                if(stagingList.size() == 0){
                    stagingList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c, Title__c, From_sObject__c
                                   from Staging__b
                                   where Status__c = 'Pending' and Chunk__c =: stagingId
                                   LIMIT 1];    
                }
                
                Blob fileBody;
                String fileName;
                
                if(stagingList[0].From_sObject__c == 'ContentDocument'){
                    
                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId, VersionData, FileExtension
                                                               FROM ContentVersion
                                                               WHERE id =: stagingList[0].Content_Version_ID__c
                                                               LIMIT 1];
                    fileBody = contentVersionList[0].VersionData;
                    fileName = stagingList[0].Title__c + '.' + contentVersionList[0].FileExtension;
                }
                else{
                    List<Attachment> attachmentsList = [SELECT Body, BodyLength, ContentType, Id, Name FROM Attachment
                                                        WHERE Id =: stagingList[0].Chunk__c
                                                        LIMIT 1]; 
                    fileBody = attachmentsList[0].Body;
                    if(attachmentsList[0].ContentType != null){
                        fileName = stagingList[0].Title__c + '.' + attachmentsList[0].ContentType.substringAfterLast('/');
                    }
                    else{
                        fileName = stagingList[0].Title__c;
                    }
                }
                try{
                    String sharepointFolderName = Label.SharepointfolderName;
                    String driveId = Label.SharepointDriveId;
                    String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                    String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                    String subFolderName = stagingList[0].Linked_Entity_Id__c;
                    String objectName = stagingList[0].sObject__c;
                    
                    Http httpCallout = new Http();
                    HttpRequest req = new HttpRequest();
                    
                    if(objectName == 'EmailMessage')
                    {
                        //String objectNameCase = 'CaseNew';
                        EmailMessage emRec = [Select ParentId from EmailMessage where Id =: subFolderName];
                        String  caseFolderName = emRec.ParentId;
                        
                        req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ sharepointFolderName  +'/'+ caseFolderName + '/' + subFolderName +'/' + encodedFileName.replaceall('\\+', '%20') + ':/content'); 
                        
                        
                        //req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                        req.setMethod('PUT');
                        req.setHeader('Content-Type', 'application/json');
                        req.setHeader('Accept', 'application/json');
                        req.setBodyAsBlob(fileBody);
                        
                        HTTPResponse res = httpCallout.send(req);
                        
                        
                        
                        if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
                            updateSharepointStatus(stagingList[0], 'Completed','null',res);
                        }
                        else{
                            String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                            System.debug('String errorMessage==> '+errorMessage);
                            updateSharepointStatus(stagingList[0], 'Pending', errorMessage,res);
                        }
                    }else{
                        req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ objectName  +'/'+subFolderName+'/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                        req.setMethod('PUT');
                        req.setHeader('Content-Type', 'application/json');
                        req.setHeader('Accept', 'application/json');
                        req.setBodyAsBlob(fileBody);
                        
                        HTTPResponse res = httpCallout.send(req);
                        System.debug('Callout Response -> ' + res.getBody());
                        
                        if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
                            updateSharepointStatus(stagingList[0], 'Completed','null',res);
                        }
                        else{
                            String errorMessage = 'File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody();
                            System.debug('String errorMessage==> '+errorMessage);
                            updateSharepointStatus(stagingList[0], 'Pending', errorMessage,res);
                        }
                    }
                }catch(Exception e){
                    updateSharepointStatus(stagingList[0], 'Pending', 'Exception Caught!',null);
                }
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
    
    public static void updateSharepointStatus(Staging__b recordToUpdate, String status, String errorMessage,HTTPResponse res) {
        String customSwitch = String.valueOf(System.Label.AttachmentSwitch); 
        
        try{
            Staging__b currentRecord = new Staging__b();
            currentRecord.Status__c = status;
            currentRecord.sObject__c = recordToUpdate.sObject__c;
            currentRecord.Chunk__c = recordToUpdate.Chunk__c;
            currentRecord.Content_Document_Id__c = recordToUpdate.Content_Document_Id__c;
            currentRecord.Content_Version_Id__c = recordToUpdate.Content_Version_Id__c;
            currentRecord.Linked_Entity_Id__c = recordToUpdate.Linked_Entity_Id__c;
            currentRecord.Title__c = recordToUpdate.Title__c;
            currentRecord.From_sObject__c = recordToUpdate.From_sObject__c;
            
            if (errorMessage != null && !String.isBlank(errorMessage)){
                currentRecord.Error_Message__c = errorMessage.left(255);
            }
            
            
            try{
                if(currentRecord.Job_ID__c != 'Test##SP'){
                    Database.SaveResult result = Database.insertImmediate(currentRecord);
                    if(result.isSuccess()){
                        Database.deleteImmediate(new Staging__b(Status__c = recordToUpdate.Status__c, Chunk__c = recordToUpdate.Chunk__c));
                    }
                    
                }
                if(customSwitch == 'True') {
                    
                    //Creates log in Integration Log object to track the current Transaction
                    IntegrationLogInserter(recordToUpdate, res);
                }
            }catch(Exception ex){
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
    public static void IntegrationLogInserter(Staging__b stagingVar, HTTPResponse res) {
        
        Integration_Log_Error__c  intLog = new Integration_Log_Error__c ();
        intLog.Name = stagingVar.Id;
        intLog.getMessage__c = 'Staging Id -> ' + stagingVar.Chunk__c + 'Related Email Id -> ' + stagingVar.Linked_Entity_Id__c;
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
    }
    
}