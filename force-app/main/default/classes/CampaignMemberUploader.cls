/**
 * @description       : 
 * @author            : Sudharshan Sriram 
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Sudharshan Sriram 
**/
public with sharing class CampaignMemberUploader {
    
    @AuraEnabled
    public static Map<String, Object> previewCsvFile(String base64Data, Id campaignId) {
        String csvData = EncodingUtil.base64Decode(base64Data).toString();
        List<String> csvLines = csvData.split('\n');
        
        Map<String, Object> response = new Map<String, Object>();
        List<String> columnHeaders = new List<String>();
        List<Map<String, String>> contactDetails = new List<Map<String, String>>();
        Map<String, Id> emailToContactMap = new Map<String, Id>();
        Boolean isHeader = true;
        Set<String> emailSet = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        
        // Track duplicates using email+accountId as key
        Map<String, Integer> duplicateTracker = new Map<String, Integer>();
        
        // First pass: collect all AccountIds and Emails
        for (String line : csvLines) {
            if (String.isBlank(line)) continue;
            
            String[] values = line.split(',');
            
            if (isHeader) {
                columnHeaders.addAll(values);
                isHeader = false;
                continue;
            }
            
            Map<String, String> contactDetail = new Map<String, String>();
            for (Integer i = 0; i < Math.min(values.size(), columnHeaders.size()); i++) {
                String header = columnHeaders[i].trim();
                String value = values[i].trim();
                contactDetail.put(header, value);
            }
            
            String accountId = contactDetail.get('AccountId');
            String email = contactDetail.get('Email')?.toLowerCase();
            
            // Track duplicates
            if (String.isNotBlank(email) && String.isNotBlank(accountId)) {
                String uniqueKey = email + '-' + accountId;
                Integer count = duplicateTracker.get(uniqueKey);
                duplicateTracker.put(uniqueKey, count == null ? 1 : count + 1);
            }
            
            if (String.isNotBlank(accountId)) {
                accountIds.add(accountId);
            }
            if (String.isNotBlank(email)) {
                emailSet.add(email);
            }
            
            contactDetails.add(contactDetail);
        }
        
        // Rest of the existing bulk queries...
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Name 
            FROM Account 
            WHERE Id IN :accountIds
        ]);
        
        Map<String, Contact> emailToContact = new Map<String, Contact>();
        for (Contact c : [
            SELECT Id, Email, AccountId 
            FROM Contact 
            WHERE Email IN :emailSet 
            AND AccountId IN :accountIds
        ]) {
            emailToContact.put((c.Email + c.AccountId).toLowerCase(), c);
        }
        
        Map<String, CampaignMember> emailToCampaignMember = new Map<String, CampaignMember>();
        for (CampaignMember cm : [
            SELECT Id, ContactId, Campaign.Name, Contact.Email 
            FROM CampaignMember 
            WHERE CampaignId = :campaignId 
            AND Contact.Email IN :emailSet
        ]) {
            emailToCampaignMember.put(cm.Contact.Email.toLowerCase(), cm);
        }
        
        // Process records with bulk queried data
        for (Map<String, String> contactDetail : contactDetails) {
            String email = contactDetail.get('Email')?.toLowerCase();
            String accountId = contactDetail.get('AccountId');
            
            contactDetail.put('status', 'Pending');
            contactDetail.put('statusClass', 'slds-text-color_default');
            contactDetail.put('Error', '');
            
            // Check for duplicates in CSV
            if (String.isNotBlank(email) && String.isNotBlank(accountId)) {
                String uniqueKey = email + '-' + accountId;
                if (duplicateTracker.get(uniqueKey) > 1) {
                    contactDetail.put('status', 'Error');
                    contactDetail.put('statusClass', 'slds-text-color_error');
                    contactDetail.put('Error', 'Duplicate entry found in CSV with same Email and AccountId');
                    continue;
                }
            }
            
            if (String.isBlank(accountId)) {
                contactDetail.put('status', 'Error');
                contactDetail.put('statusClass', 'slds-text-color_error');
                contactDetail.put('Error', 'AccountId is required.');
                continue;
            }
            
            Account acc = accountMap.get(accountId);
            if (acc == null) {
                contactDetail.put('status', 'Error');
                contactDetail.put('statusClass', 'slds-text-color_error');
                contactDetail.put('Error', 'Invalid AccountId: Account not found');
                continue;
            }
            
            contactDetail.put('AccountName', acc.Name);
            
            String emailAccountKey = (email + accountId).toLowerCase();
            Contact existingContact = emailToContact.get(emailAccountKey);
            
            if (existingContact != null) {
                contactDetail.put('status', 'Existing');
                contactDetail.put('statusClass', 'slds-text-color_success');
                contactDetail.put('contactId', existingContact.Id);
            } else {
                contactDetail.put('status', 'New');
                contactDetail.put('statusClass', 'slds-text-color_default');
            }
            
            if (emailToCampaignMember.containsKey(email)) {
                CampaignMember cm = emailToCampaignMember.get(email);
                contactDetail.put('CampaignName', cm.Campaign.Name);
                contactDetail.put('status', 'Already in Campaign');
                contactDetail.put('statusClass', 'slds-text-color_warning');
                contactDetail.put('Error', 'Contact already exists in this campaign');
            }
        }
        
        response.put('columns', columnHeaders);
        response.put('data', contactDetails);
        return response;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> insertSelectedContacts(List<Map<String, String>> selectedContacts, Id campaignId) {
        List<Contact> newContacts = new List<Contact>();
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        List<Map<String, String>> resultList = new List<Map<String, String>>();
        
        Map<String, Contact> emailToContactMap = new Map<String, Contact>();
        Map<String, Map<String, String>> emailToDetailMap = new Map<String, Map<String, String>>();
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Process in batches of 100 to handle governor limits
            Integer batchSize = 100;
            
            for (Integer i = 0; i < selectedContacts.size(); i += batchSize) {
                Integer endIndex = Math.min(i + batchSize, selectedContacts.size());
                List<Map<String, String>> batchList = new List<Map<String, String>>();
                
                // Manually create subset of the list
                for (Integer j = i; j < endIndex; j++) {
                    batchList.add(selectedContacts[j]);
                }
                
                processContactBatch(batchList, campaignId, resultList);
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            for (Map<String, String> contactDetail : selectedContacts) {
                Map<String, String> resultDetail = new Map<String, String>();
                resultDetail.put('Email', contactDetail.get('Email'));
                resultDetail.put('Error', 'System Error: ' + e.getMessage());
                resultList.add(resultDetail);
            }
        }
        
        return resultList;
    }
    
    private static void processContactBatch(List<Map<String, String>> batch, Id campaignId, List<Map<String, String>> resultList) {
        List<Contact> newContacts = new List<Contact>();
        Map<String, Map<String, String>> emailToDetailMap = new Map<String, Map<String, String>>();
        system.debug('batch**'+batch);
        // Prepare contacts and build email mapping
        for (Map<String, String> contactDetail : batch) {
            String email = contactDetail.get('Email')?.toLowerCase();
            emailToDetailMap.put(email, contactDetail);
            
            if (contactDetail.get('status') == 'New') {
                system.debug('newcontbef***');
                Contact newContact = new Contact();
                    newContact.FirstName = contactDetail.get('FirstName');
                    newContact.LastName = contactDetail.get('LastName');
                    newContact.Email = contactDetail.get('Email');
                    newContact.AccountId = contactDetail.get('AccountId');
                if(contactDetail.get('Contact_Type__c')!= Null && contactDetail.get('Contact_Type__c')!='')
                {
                    system.debug('newcontbefhere***');
                    newContact.Contact_Type__c = contactDetail.get('Contact_Type__c');
                }
                 if(contactDetail.get('RecordType')!= Null && contactDetail.get('RecordType')!= '')
                {
                    system.debug('newcontbefthere***');
                   	newContact.RecordTypeId = contactDetail.get('RecordType');
                }   	//RecordTypeId=contactDetail.get('RecordType')!= Null?contactDetail.get('RecordType'):''
                system.debug('newcont***'+newContact);
                newContacts.add(newContact);
            }
        }
        system.debug('new***'+newContacts);
        // Insert new contacts
        if (!newContacts.isEmpty()) {
            List<Database.SaveResult> contactResults = Database.insert(newContacts, false);
            for(Database.SaveResult each:contactResults)
            {
                System.debug('contactResults***'+contactResults.size());
                System.debug('each***'+each);
            }
            system.debug(contactResults);
            processContactResults(contactResults, newContacts, emailToDetailMap, resultList, campaignId);
        }
        
        // Process existing contacts
        Set<Id> existingContactIds = new Set<Id>();
        for (Map<String, String> contactDetail : batch) {
            if (contactDetail.get('status') == 'Existing') {
                existingContactIds.add(contactDetail.get('contactId'));
            }
        }
        
        if (!existingContactIds.isEmpty()) {
            List<CampaignMember> existingCampaignMembers = new List<CampaignMember>();
            for (Id contactId : existingContactIds) {
                existingCampaignMembers.add(new CampaignMember(
                    CampaignId = campaignId,
                    ContactId = contactId
                ));
            }
            
            if (!existingCampaignMembers.isEmpty()) {
                List<Database.SaveResult> memberResults = Database.insert(existingCampaignMembers, false);
                processCampaignMemberResults(memberResults, existingCampaignMembers, batch, resultList);
            }
        }
    }
    
    private static void processContactResults(List<Database.SaveResult> results, List<Contact> contacts, 
                                           Map<String, Map<String, String>> emailToDetailMap, 
                                           List<Map<String, String>> resultList, Id campaignId) {
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        
        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results[i];
            Contact c = contacts[i];
            String email = c.Email?.toLowerCase();
            Map<String, String> resultDetail = new Map<String, String>();
            resultDetail.put('Email', email);
            
            if (!sr.isSuccess()) {
                String errorMsg = 'Contact Creation Failed: ' + 
                    String.join(sr.getErrors().get(0).getMessage().split('\n'), ' ');
                resultDetail.put('Error', errorMsg);
                resultList.add(resultDetail);
            } else {
                campaignMembers.add(new CampaignMember(
                    CampaignId = campaignId,
                    ContactId = sr.getId()
                ));
            }
        }
        
        if (!campaignMembers.isEmpty()) {
            List<Database.SaveResult> memberResults = Database.insert(campaignMembers, false);
            processCampaignMemberResults(memberResults, campaignMembers, new List<Map<String, String>>(emailToDetailMap.values()), resultList);
        }
    }
    
    private static void processCampaignMemberResults(List<Database.SaveResult> results, List<CampaignMember> members, 
                                                   List<Map<String, String>> contactDetails, List<Map<String, String>> resultList) {
        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results[i];
            if (!sr.isSuccess()) {
                Map<String, String> resultDetail = new Map<String, String>();
                resultDetail.put('Email', contactDetails[i].get('Email'));
                resultDetail.put('Error', 'Campaign Member Creation Failed: ' + 
                               String.join(sr.getErrors().get(0).getMessage().split('\n'), ' '));
                resultList.add(resultDetail);
            }
        }
    }
}