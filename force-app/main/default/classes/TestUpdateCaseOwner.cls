@isTest(seeAllData = true) 
public class TestUpdateCaseOwner{ 
    @isTest 
    public static void positiveTest(){ 
        system.runAs(new User(Id=userInfo.getUserId())){ 
            //fetch queue assign for case object 
            QueueSobject que = [Select SobjectType, QueueId From QueueSobject Where SobjectType = 'Case' Limit 1]; 
            List<Contact> listOfContact = TestDataFactory.contactTestData2(true);
            //crate new account 
            Account acc = new Account(Name = 'testAccount'); 
            insert acc; 
            //create new case to test before update 
            Case cs1 = new Case(); 
            cs1.AccountId = acc.Id; 
            cs1.Origin = 'Web'; 
            cs1.status = 'Open'; 
            cs1.Priority = 'Medium'; 
            cs1.Type = 'Admin';  
            cs1.Subject = 'test subject'; 
            cs1.OwnerId = que.QueueId; 
            cs1.Reason = 'Duplicate';
            cs1.ContactId = listOfContact[0].Id;
            insert cs1; 
            //check trigger for before upadte 
            cs1.status = 'Closed'; 
            update cs1; 
            cs1 = [Select id, OwnerId From Case Where Id =: cs1.Id Limit 1]; 
            //assert to check if ownerId is changed or not 
            system.assertEquals(userInfo.getUserId(),cs1.OwnerId); 
            
            //create new case to test before insert 
            Case cs2 = new Case(); 
            cs2.AccountId = acc.Id; 
            cs2.Origin = 'Web'; 
            cs2.status = 'Closed'; 
            cs2.Priority = 'Medium'; 
            cs2.Type = 'Admin';  
            cs2.Subject = 'test subject'; 
            cs2.OwnerId = que.QueueId; 
            system.debug('#### Case Owner :'+cs2.OwnerId); 
            cs2.Reason = 'Duplicate';
              cs2.ContactId = listOfContact[0].Id;
            insert cs2; 
            //fetch newly created case 
            cs2 = [Select id, OwnerId From Case Where Id =: cs2.Id Limit 1]; 
            //assert to check if ownerId is changed or not 
            system.assertEquals(userInfo.getUserId(),cs2.OwnerId); 
        } 
    } 
    
}