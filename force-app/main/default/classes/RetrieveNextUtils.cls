global with sharing class RetrieveNextUtils {
    webService static Id retrieveNextCase(String userId)
    {
        //Really we're only specifying the user ID for the sake of the test methods
        if (userId=='') {
            //Use the currently running user
            userId = UserInfo.getUserId();
        }
        
        //First find out which queues this user is a member of
        List<Id> listGroupIds = getQueuesForUser(userId);
        
        if(listGroupIds.size()>0) 
        {
            //Find an open case that is assigned to one of those queues
            Case caseObj = [select c.Id,c.OwnerId from Case c where 
                                                        c.IsClosed=false 
                                                        and c.OwnerId in :listGroupIds 
                                                        limit 1 
                                                        for update];
                                                
            if (caseObj!=null) {        
                //If we found one, assign it to the current user
                caseObj.OwnerId = userId;
                update caseObj;
                
                return caseObj.Id;
            }
        }
        
        return null;
    }
    
    webService static Id retrieveNextLead(String userId)
    {
        //Really we're only specifying the user ID for the sake of the test methods
        if (userId=='') {
            //Use the currently running user
            userId = UserInfo.getUserId();
        }
        
        //First find out which queues this user is a member of
        List<Id> listGroupIds = getQueuesForUser(userId);
        
        if(listGroupIds.size()>0) 
        {
            //Find an open lead that is assigned to one of those queues
            List<Lead> leads = [select l.Id,l.OwnerId from Lead l where 
                                                        l.IsConverted=false 
                                                        and l.OwnerId in :listGroupIds 
                                                        limit 1 
                                                        for update];
                                                
            if (leads.size()>0) {       
                //If we found one, assign it to the current user
                leads[0].OwnerId = userId;
                update leads;
                
                return leads[0].Id;
            }
        }
        
        return null;
    }
    
    //Returns a list of ids of queues that this user is a member of
    public static List<Id> getQueuesForUser(String userId) 
    {
        List<Id> listGroupIds = new List<Id>();
        List<GroupMember> listGroupMembers = [Select g.GroupId From GroupMember g 
                                                where g.Group.Type='Queue'
                                                and g.UserOrGroupId=:userId];
                                                
        if (listGroupMembers!=null && listGroupMembers.size()>0) {      
            for (GroupMember gm:listGroupMembers) {
                listGroupIds.add(gm.GroupId);
            }
        }
        
        return listGroupIds;
    }
    
    public static Group createTestGroup()
    {
        Group g = new Group(Type='Queue',Name='testRetrieveNextCase');
        insert g;
        
        //Make this queue assignable to leads and cases
        List<QueueSobject> qs = new List<QueueSobject>();
        qs.add(new QueueSobject(QueueId=g.Id,SObjectType='Case'));
        qs.add(new QueueSobject(QueueId=g.Id,SObjectType='Lead'));        
        insert qs;
        
        return g;
    }
    
    static User createTestUser() {
        User user = new User();
        user.Username = 'test'+System.currentTimeMillis()+'@RetrieveNextUtils.com';
        user.LastName = 'LastTestName';
        user.Email = 'test@RetrieveNextUtils.com';
        user.alias = 'testAl';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user.LanguageLocaleKey = 'en_US';
        insert user;
        //setUser(user);
        
        return user;
     }
    
    public static testMethod void testRetrieveNextLead()
    {        
      User u = createTestUser();
      
        Group g = createTestGroup();
        
        GroupMember gm = new GroupMember(UserOrGroupId=u.Id,GroupId=g.Id);
        insert gm;
        
        Test.startTest();        
        
        //We have to runAs so that we don't get a MIXED_DML_EXCEPTION
        System.runAs(u) {
          Lead l = new Lead(LastName='Test',OwnerId=g.Id,Company='Test');
          insert l;
          
          Id leadId = retrieveNextLead(u.Id);
          System.assertEquals(leadId,l.Id);
          
          Lead ownedLead = [select OwnerId from Lead where Id=:l.Id];
          System.assertEquals(ownedLead.OwnerId,u.Id);
        }
    }
        
    
    public static testMethod void testNegativeRetrieveNextLead()
    {       
      User u = createTestUser();
       
        Group g = createTestGroup();
        
        Test.startTest();  
        
        //We have to runAs so that we don't get a MIXED_DML_EXCEPTION
        System.runAs(u) {
          //Do not insert this user in the queue -- he should not get the case
          
          Lead l = new Lead(LastName='Test',OwnerId=g.Id,Company='Test');
          insert l;
          
          Id leadId = retrieveNextLead(u.Id);
          System.assertEquals(leadId,null);
          
          Lead ownedLead = [select OwnerId from Lead where Id=:l.Id];
          System.assertNotEquals(ownedLead.OwnerId,u.Id);
        }
    }
    
    public static testMethod void testRetrieveNextCase()
    {    
      User u = createTestUser();
       
        Group g = createTestGroup();
        
        GroupMember gm = new GroupMember(UserOrGroupId=u.Id,GroupId=g.Id);
        insert gm;
        
        Test.startTest();  
        //We have to runAs so that we don't get a MIXED_DML_EXCEPTION
        System.runAs(u) {
          Case c = new Case(Subject='Test',OwnerId=g.Id);
          insert c;
          
          Id caseId = retrieveNextCase(u.Id);
          System.assertEquals(caseId,c.Id);
          
          Case ownedCase = [select OwnerId from Case where Id=:c.Id];
          System.assertEquals(ownedCase.OwnerId,u.Id);
        }
    }
        
    
    public static testMethod void testNegativeRetrieveNextCase()
    {    
      User u = createTestUser();
               
        Group g = createTestGroup();
        
        Test.startTest();  
        
        //We have to runAs so that we don't get a MIXED_DML_EXCEPTION
        System.runAs(u) {
          
          //Do not insert this user in the queue -- he should not get the case
          Case c = new Case(Subject='Test',OwnerId=g.Id);
          insert c;
          
          Id caseId = retrieveNextCase(u.Id);
          System.assertEquals(caseId,null);
          
          Case ownedCase = [select OwnerId from Case where Id=:c.Id];
          System.assertNotEquals(ownedCase.OwnerId,u.Id);
        }
    }
}