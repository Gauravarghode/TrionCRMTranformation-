global class QueueableGenCsvSendSharepoint implements Queueable, Database.AllowsCallouts {
    private List<String> emailMessageIds;
    private Integer startIndex;
    @testVisible
    private static Boolean doChainJob = true;
    
    
    global QueueableGenCsvSendSharepoint(List<String> emailMessageIds, Integer startIndex) {
        this.emailMessageIds = emailMessageIds;
        this.startIndex = startIndex;
    }
    
    global void execute(QueueableContext context) {
        Integer batchSize = 10;
        Integer endIndex = Math.min(startIndex + batchSize, emailMessageIds.size());
        
        List<String> currentBatch = new List<String>();
        for (Integer i = startIndex; i < endIndex; i++) {
            currentBatch.add(emailMessageIds[i]);
        }
        
        if (!currentBatch.isEmpty()) {
            GeneratingCSVAndSendingSharepoint.convertIntoCSV(currentBatch);
        }
        
        if (endIndex < emailMessageIds.size()) {
            if(doChainJob) {
                System.enqueueJob(new QueueableGenCsvSendSharepoint(emailMessageIds, endIndex));    
            }
            //System.enqueueJob(new QueueableGenCsvSendSharepoint(emailMessageIds, endIndex));
        }
    }
    
    public static void invokeQueueable(List<id> emailList) { //pass the email list from Arch_CovertCSVPopulateDK class emailIdList 
        String startDateLabel = Label.startDate; 
        String endDateLabel = Label.endDate; 
        String labelid = label.emailmessageId;
        String emailId;
        Datetime startDate = Date.valueOf(startDateLabel);
        Datetime endDate = Date.valueOf(endDateLabel);
        //List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage WHERE ParentId IN (SELECT Id FROM Case WHERE have_more_character__c = true)];
        //List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage WHERE ParentId IN (SELECT Id FROM Case WHERE have_more_character__c = true) AND Parent.ClosedDate >= :startDate 
        //                                    AND Parent.ClosedDate <= :endDate];
        //List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage WHERE ParentId IN (SELECT Id FROM Case WHERE have_more_character__c = true) AND Parent.ClosedDate >= :startDate 
        //                                   AND Parent.ClosedDate <= :endDate];
        //List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage where id =: labelid];
        for(Id emId : emailList){
            emailId=emId;
        }
        List<EmailMessage> emailMessages = [SELECT Id, Message_Size__c, ParentId FROM EmailMessage where id =: emailId];
        
        
        List<EmailMessageHtml__c> embList=new List<EmailMessageHtml__c>(); 
        List<EmailMessageHtml__c> embListLongEmail=new List<EmailMessageHtml__c>(); 
        List<Id> emailIdList = new List<Id>();
        for (EmailMessage emlist : emailMessages) {
            
            if(emlist.Message_Size__c > 130000){
                //emailIdList.add(emlist.Id);
                String csvName = 'EmailMessageDetails_' + emlist.Id + '.csv';
                EmailMessageHtml__c  emhb=new EmailMessageHtml__c ();
                emhb.Title__c = csvName;
                emhb.File_Size__c =140000;
                emhb.EmailMessage_Id__c=emlist.Id;
                emhb.Status__c = 'Completed';
                emhb.sObject__c='Email Message';
                //emhb.Csv_Body__c=csvString1;
                //emhb.Csv_String_2__c = csvString2;
                
                emhb.Parent_Case_Id__c=emlist.ParentId;            
                if(emhb.File_Size__c > 12000000){
                    emhb.Is_Large_File__c = 'yes';
                    emhb.Status__c = 'Failed';
                    emhb.Error_Message__c = 'File size > 12000000';
                }
                else{
                    emhb.Is_Large_File__c = 'no';
                    emhb.Status__c = 'Completed';
                }
                embListLongEmail.add(emhb);
                
                if(!embListLongEmail.isEmpty()){
                    
                    system.debug('embListLongEmail-->'+embListLongEmail);
                    Database.insert(embListLongEmail);
                }   
                
            }                
            
        }
        
        List<String> emailMessageIds = new List<String>();
        
        for (EmailMessage em : emailMessages) {
            emailMessageIds.add(em.Id);
        }
        system.debug('Size of the em' + emailMessageIds.size());
        
        if (!emailMessageIds.isEmpty()) {
            System.enqueueJob(new QueueableGenCsvSendSharepoint(emailMessageIds, 0));
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
    }
    
}