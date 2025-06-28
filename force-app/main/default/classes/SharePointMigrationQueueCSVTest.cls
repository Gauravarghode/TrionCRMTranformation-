@isTest
public class SharePointMigrationQueueCSVTest {
    
    @istest
    public static void createData(){
        
        List<EmailMessage> emailMessageList = NEW List<EmailMessage>();
        EmailMessage emailMessage = NEW EmailMessage();
        emailMessage.FromAddress ='123@testSalesforce.com';
        emailMessage.ToAddress ='321@testSalesforce.com';
        emailMessage.Headers ='Test Header';
        emailMessage.HtmlBody ='Test HTML Body';
        emailMessageList.add(emailMessage);
        insert emailMessageList;
        
        List<EmailMessageHtml__c> EmailMessageHtmlbList = NEW List<EmailMessageHtml__c>();
        EmailMessageHtml__c emailMessageHtmlBO = NEW EmailMessageHtml__c();
        //emailMessageHtmlBO.Csv_body__c = emailMessageList[0].HtmlBody;//'This is a Test csv Body!';
        emailMessageHtmlBO.EmailMessage_Id__c = emailMessageList[0].id;
        emailMessageHtmlBO.File_Body__c = emailMessageList[0].HtmlBody;
        emailMessageHtmlBO.sObject__c = 'EmailMessage';
        emailMessageHtmlBO.Status__c = 'Not Started';
        emailMessageHtmlBO.Title__c = 'Test Class';
        EmailMessageHtmlbList.add(emailMessageHtmlBO);
        
        List<Integration_Log_Error__c> intErrList=new List<Integration_Log_Error__c>();
        Integration_Log_Error__c intLog=new Integration_Log_Error__c();
        intLog.getMessage__c = 'Exception';
        intLog.getCause__c ='Status code is -> 201';
        intLog.getLineNumber__c='8';
        //intLog.getNumDml__c =String.valueOf(e.getNumDml());
        intLog.getStackTraceString__c='Status is -> Created';            
        intLog.getTypeName__c='Math';            
        intErrList.add(intLog);
        
        if(intErrList.size() > 0){
            system.debug('intList-->'+intErrList);
            insert(intErrList);
        }
        
        //SharePointMigrationQueueCSV queueInstance = new SharePointMigrationQueueCSV(EmailMessageHtmlbList);
        Arch_SharePointMigrationQueueCSV queueInstance = new Arch_SharePointMigrationQueueCSV(EmailMessageHtmlbList);
        ID jobID = System.enqueueJob(queueInstance);
    }
    @isTest
    static void testCoverage(){
        Arch_SharePointMigrationQueueCSV.testCoverage();
    }
}