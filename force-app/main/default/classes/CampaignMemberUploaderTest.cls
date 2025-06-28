@isTest
public class CampaignMemberUploaderTest {

    @isTest
    static void testPreviewCsvFile() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30),
            Status = 'Active'
        );
        insert testCampaign;

        // Prepare CSV data (base64 encoded)
        String csvData = 'AccountId,Email,FirstName,LastName\n' + 
                          testAccount.Id + ',john.doe@example.com,John,Doe\n';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvData));

        // Call the method
        Test.startTest();
        Map<String, Object> response = CampaignMemberUploader.previewCsvFile(base64Data, testCampaign.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, ((List<Map<String, String>>)response.get('data')).size());
        System.assertEquals('Existing', ((List<Map<String, String>>)response.get('data')).get(0).get('status'));
    }
   
    @isTest
    static void testPreviewCsvFileWithMissingAccountId() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30),
            Status = 'Active'
        );
        insert testCampaign;

        // Prepare CSV data (base64 encoded)
        String csvData = 'AccountId,Email,FirstName,LastName\n' + 
                          '' + ',john.doe@example.com,John,Doe\n';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvData));

        // Call the method
        Test.startTest();
        Map<String, Object> response = CampaignMemberUploader.previewCsvFile(base64Data, testCampaign.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, ((List<Map<String, String>>)response.get('data')).size());
        System.assertEquals('Error', ((List<Map<String, String>>)response.get('data')).get(0).get('status'));
        System.assertEquals('AccountId is required.', ((List<Map<String, String>>)response.get('data')).get(0).get('Error'));
    }

    @isTest
    static void testPreviewCsvFileWithDuplicateContacts() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = testAccount.Id
        );
        Contact testContact2 = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            AccountId = testAccount.Id
        );
        insert new List<Contact>{ testContact1, testContact2 };

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30),
            Status = 'Active'
        );
        insert testCampaign;

        // Prepare CSV data (base64 encoded)
        String csvData = 'AccountId,Email,FirstName,LastName\n' + 
                          testAccount.Id + ',john.doe@example.com,John,Doe\n' + 
                          testAccount.Id + ',john.doe@example.com,John,Doe\n';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvData));

        // Call the method
        Test.startTest();
        Map<String, Object> response = CampaignMemberUploader.previewCsvFile(base64Data, testCampaign.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(2, ((List<Map<String, String>>)response.get('data')).size());
        System.assertEquals('Error', ((List<Map<String, String>>)response.get('data')).get(0).get('status'));
        System.assertEquals('Duplicate entry found in CSV with same Email and AccountId', ((List<Map<String, String>>)response.get('data')).get(0).get('Error'));
    }

    @isTest
    static void testInsertSelectedContacts() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account 2');
        insert testAccount;

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign 2',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30),
            Status = 'Active'
        );
        insert testCampaign;

        // Prepare sample data for insertion
        List<Map<String, String>> selectedContacts = new List<Map<String, String>>();

        // First contact
        Map<String, String> contactData1 = new Map<String, String> {
            'AccountId' => testAccount.Id,
            'Email' => 'jane.doe@example.com',
            'FirstName' => 'Jane',
            'LastName' => 'Doe',
            'status' => 'New'
        };
        selectedContacts.add(contactData1);

        // Second contact
        Map<String, String> contactData2 = new Map<String, String> {
            'AccountId' => testAccount.Id,
            'Email' => 'john.smith@example.com',
            'FirstName' => 'John',
            'LastName' => 'Smith',
            'status' => 'New'
        };
        selectedContacts.add(contactData2);

        // Call the method
        Test.startTest();
        List<Map<String, String>> results = CampaignMemberUploader.insertSelectedContacts(selectedContacts, testCampaign.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(2, results.size()); // Check that we have results for both contacts
        System.assertEquals('jane.doe@example.com', results[0].get('Email'));
        System.assertEquals('john.smith@example.com', results[1].get('Email'));
        System.assertNotEquals(null, results[0].get('Error')); // Check for any error message for the first contact
        System.assertNotEquals(null, results[1].get('Error')); // Check for any error message for the second contact
    }

    @isTest
    static void testInsertExistingContact() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account 3');
        insert testAccount;

        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Email = 'existing.contact@example.com',
            AccountId = testAccount.Id
        );
        insert existingContact;

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign 3',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30),
            Status = 'Active' // Ensure this status allows member creation
        );
        insert testCampaign;
        CampaignMember con=new CampaignMember();
        con.CampaignId=testCampaign.id;
        con.contactId=existingContact.id;
        
        

        // Prepare data for existing contact
        Map<String, String> contactData = new Map<String, String>{
            'AccountId' => testAccount.Id,
            'Email' => 'existing.contact@example.com',
            'FirstName' => 'Existing',
            'LastName' => 'Contact',
            'status' => 'Existing',
            'contactId' => existingContact.Id
        };
        List<Map<String, String>> selectedContacts = new List<Map<String, String>>{ contactData };

        // Call the method
        Test.startTest();
        List<Map<String, String>> results = CampaignMemberUploader.insertSelectedContacts(selectedContacts, testCampaign.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size());
        System.assertEquals('existing.contact@example.com', results[0].get('Email'));
        System.assertNotEquals(null, results[0].get('Error'), 'Expected an error message for existing contact in the campaign.');
    }

    @isTest
    static void testInsertSelectedContacts_ErrorHandling() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account 4');
        insert testAccount;

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign 4',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30),
            Status = 'Planned' // Ensure this status allows member creation
        );
        insert testCampaign;

        // Prepare invalid data to trigger an exception
        Map<String, String> contactData = new Map<String, String> {
            'AccountId' => testAccount.Id,
            'Email' => 'invalid.email@example.com', // Invalid email
            'FirstName' => 'Invalid',
            'LastName' => 'Contact',
            'status' => 'New'
        };
        List<Map<String, String>> selectedContacts = new List<Map<String, String>>{ contactData };

        // Call the method
        Test.startTest();
        List<Map<String, String>> results = CampaignMemberUploader.insertSelectedContacts(selectedContacts, testCampaign.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size());
        System.assertEquals('invalid.email@example.com', results[0].get('Email'));
        System.assertNotEquals(null, results[0].get('Error'), 'Expected an error message due to invalid email format.');

        // Verify that the contact was not created in the database
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'invalid.email@example.com'];
        System.assertEquals(1, contacts.size(), 'No contact should have been created due to invalid email.');
    }

    @isTest
    static void testInsertSelectedContacts_MissingRequiredFields() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account 5');
        insert testAccount;

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign 5',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(30),
            Status = 'Active'
        );
        insert testCampaign;

        // Prepare data with missing required fields (e.g., missing AccountId)
        Map<String, String> contactData = new Map<String, String> {
            'Email' => 'missing.account@example.com', // Missing AccountId
            'FirstName' => 'Missing',
            'LastName' => 'Account',
            'status' => 'New'
        };
        List<Map<String, String>> selectedContacts = new List<Map<String, String>>{ contactData };

        // Call the method
        Test.startTest();
        List<Map<String, String>> results = CampaignMemberUploader.insertSelectedContacts(selectedContacts, testCampaign.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size());
        System.assertEquals('missing.account@example.com', results[0].get('Email'));
        System.assertNotEquals(null, results[0].get('Error'), 'Expected an error message due to missing AccountId.');

        // Verify that the contact was not created in the database
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'missing.account@example.com'];
        System.assertEquals(0, contacts.size(), 'No contact should have been created due to missing AccountId.');
    }

}