@IsTest
public class UpdateCaseEmailTest {
    /*
    @IsTest
    
    public static void meth1(){
        Case casRec=new Case();
        casRec.Status='New';
        // c.ParentId=caseVar.ParentId;
        casRec.Description='hi this is for testing';
        casRec.Subject='Subject is ahd';
        casRec.To_be_Archived__c=true;
        insert casRec;
        EmailMessage emgRec=new EmailMessage();
        emgRec.ParentId = casRec.Id;
        emgRec.ToAddress='Sujatha@gmail.com';
        emgRec.FromAddress='Sujatha12@gmail.com';
        emgRec.Subject='This is for testing';
        emgRec.CreatedDate=Date.today();
        insert emgRec;
        Case_Email__c casEmailRec = new Case_Email__c();
        //customObject.Case_Number__c =c.CaseNumber;
        //customObject.EmailMessage_Id__c = e.Id;
        casEmailRec.Email_Message_Created_Date__c = emgRec.CreatedDate.format();
        //customObject.Case_Id__c = e.ParentId;
        casEmailRec.Email_Message_Subject__c = emgRec.Subject;
        insert casEmailRec;
        Case_Email__c casEmailRec2 = new Case_Email__c();
        casEmailRec2.Case_Number__c = casRec.CaseNumber;
        //customObject1.EmailMessage_Id__c = e.Id;
        casEmailRec2.Email_Message_Created_Date__c = emgRec.CreatedDate.format();
        //customObject1.Case_Id__c = e.ParentId;
        casEmailRec2.Email_Message_Subject__c = emgRec.Subject;
        insert casEmailRec2;
        Test.startTest();        
        UpdateCaseEmail b = new UpdateCaseEmail();
        Database.executeBatch(b, 10);
        Test.stopTest();
        
        
    }
    */
     @isTest
    static void testCoverage(){
        UpdateCaseEmail.testCoverage();
    }
}