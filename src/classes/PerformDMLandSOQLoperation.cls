/**
*  Description     :  Perform DML and SOQL operations, insert opportunity with account reference.
*
*  Created By      :  Jay Chand Yadav
*
*  Created Date    :  07/11/2022
*
*  Revision Logs   :    V1.0 - Created - jay Chand Yadav
**/
public with sharing class PerformDMLandSOQLoperation {

    /**
    *   @description    :  Insert ten Account Records and pass list delete and update methods 
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void insertAccountRecords() {

        List<Account> listOfAccountRecords = new List<Account>();
        Account accInsert;
        for(Integer i=1; i<=10; i++) {
            accInsert = new Account();
            accInsert.Name = 'Account ' + i;
            listOfAccountRecords.add(accInsert);
        }
        if(!listOfAccountRecords.isEmpty()) {
	    insert listOfAccountRecords;
	}
    }

    /**
    *   @description    :   Account records for deletion
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void recordSetOfDeletion() {
        
        Set<String> setOfDeletionRecord = new Set<String>{'Account 1', 'Account 2', 'Account 3', 'Account 4', 'Account 5'};
        deleteAccountRecords(setOfDeletionRecord);
    }
    
    /**
    *   @description    :  Delete account records 
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void deleteAccountRecords(Set<String> namesOfAccount) {
 
	List<Account>  listOfAccountRecords = new List<Account>();
        for(Account acc : [SELECT Id, name from Account WHERE name IN :namesOfAccount])
        {
            listOfAccountRecords.add(acc);     
            System.debug(acc);
        }
        if(!listOfAccountRecords.isEmpty()) {
	    delete listOfAccountRecords;
	}
    }

    /**
    *   @description    :   Account Records for updation
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
	
    public static void recordSetOfUpdation() {
        
        Set<String> setOfUpdationRecord = new Set<String>{'Account 6', 'Account 7', 'Account 8', 'Account 9', 'Account 10'};
        updateAccountRecords(setOfUpdationRecord);
    }
    /**
    *   @description    :  Update Account records the parameters passed by another method
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void updateAccountRecords(Set<String> namesOfAccountRecords) {

        List<Account> listOfAccountRecords = new List<Account>();
        for(Account acc : [SELECT Id, Name from Account WHERE name IN :namesOfAccountRecords])
        {
            for(Integer i = 6; i <= 10; i++) {
                if(('Account '+i).equals(acc.Name)) {
                    acc.Name = 'Account ' + (i - 5);
                    listOfAccountRecords.add(acc);
                    System.debug(acc);
                }
            }      
        } 
        if(!listOfAccountRecords.isEmpty()) {
	    update listOfAccountRecords;
	}
    }

    /**
    *   @description    :  Using upsert and update contact description whose department is finance
                           if department is not equal to finance so creating new contact.
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void updateContactRecord() {

        List<Contact> updateList = new List<Contact>();
        for(Contact con : [SELECT Department, Description FROM Contact]) {

            if(con.Department == 'Finance') {
                con.Description = 'New description';
                updateList.add(con);
            }
            else {
                Contact newContact = new Contact(department = 'Other',lastName = 'Smith');
                updateList.add(newContact);
            }
        }
        if(!updateList.isEmpty()){
	    upsert updateList;
	}
    }

    /**
    *   @description    :  Merging accounts and add mergeAcct Id in contact
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void mergeAccounts() {
        // Insert new accounts
        List<Account> listOfAccountRecords = new List<Account>{
            new Account(name='Acme Inc.'),
            new Account(name='Acme')
        };                                        
        insert listOfAccountRecords;

        // Queries to get the inserted accounts 
        List<Account> masterAcct = [SELECT Id, Name FROM Account WHERE Name IN ('Acme Inc.', 'Acme')];
        
        // Add a contact to the account to be merged
        Contact c = new Contact(FirstName='Joe',LastName='Merged');
        c.AccountId = masterAcct.get(1).Id;
        insert c;

        try {
            merge masterAcct.get(0) masterAcct.get(1);
        } catch (DmlException e) {
        // Process exception
        System.debug('An unexpected error has occurred: ' + e.getMessage()); 
        }

        // Once the account is merged with the master account,
        // the related contact should be moved to the master record.
        masterAcct = [SELECT Id, Name, (SELECT FirstName,LastName From Contacts) 
                     FROM Account 
		     WHERE Name = 'Acme Inc.' 
		     LIMIT 1];
        System.assert(masterAcct.get(0).getSObjects('Contacts').size() > 0);
        System.assertEquals('Joe', masterAcct.get(0).getSObjects('Contacts')[0].get('FirstName'));
        System.assertEquals('Merged', masterAcct.get(0).getSObjects('Contacts')[0].get('LastName'));

        // Verify that the merge record got deleted
        Account[] result = [SELECT Id, Name FROM Account WHERE Id=:masterAcct.get(1).Id];                  
        System.debug(result.size());
    }

    /**
    *   @description    :   Insert Opportunity With Account Reference
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void insertOpportunityWithAccountReference() {

	Account accountObject = new Account(SLASerialNumber__c='SAP111113', Name='Mark');
        insert accountObject;
        Opportunity newOpportunity = new Opportunity(
       	    Name = 'OpportunityWithAccountInsert',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(7));

        // Create the parent record reference.
        // An account with external ID = 'SAP111111' already exists.
        // This sObject is used only for foreign key reference
        // and doesn't contain any other fields.
        Account accountReference = new Account(
        SLASerialNumber__c='SAP111113'); // The id should be exist on account otherwise it won't work

        // Add the account sObject to the opportunity.
        newOpportunity.Account = accountReference;

        // Create the opportunity.
        Database.SaveResult results = Database.insert(newOpportunity);
    }

    /**
    *   @description    :   Create Parent and Child Records Single Statement Using ForeignKey
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void createParentChildRecordSingleStatementUsingForeignKey() {

	Account accountObj = new Account(Name='Hallie', SLASerialNumber__c='SAP111115');
        insert accountObj;
        Date dt = Date.today();
        dt = dt.addDays(7);
        Opportunity newOpportunity = new Opportunity(
            Name='OpportunityWithAccountInsert',
            StageName='Prospecting',
            CloseDate=dt);
        
        Account accountReference = new Account(
            SLASerialNumber__c='SAP111115');             
        newOpportunity.Account = accountReference;
        
        // Create the Account object to insert.
        // Same as above but has Name field.
        // Used for the insert.
        // Account parentAccount = new Account(
        // Name='Hallie',
        // SLASerialNumber__c='SAP111114');            
        
        // Create the account and the opportunity.
        Database.SaveResult[] results = Database.insert(new SObject[] {
            accountObj, newOpportunity });
        
        // Check results.
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
            System.debug('Successfully created ID: '
                  + results[i].getId());
            } else {
            System.debug('Error: could not create sobject '
                  + 'for array element ' + i + '.');
            System.debug('The error reported was: '
                  + results[i].getErrors()[0].getMessage() + '\n');
            }
        }
    }

    /**
    *   @description    :   Update Contacts Records using map
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 11/07/2022 - Developer Name - Jay Chand Yadav
    **/
    public static void updateContactRecordsWithMap() {

        List<Contact> updatedList = new List<Contact>();
        Map<Id, Contact> mapWithContacts = new Map<Id, Contact>();
        for(Contact con : [SELECT Department, Description From Contact WHERE Department = 'Management']) {
            con.Description = 'New Management';
            // Add updated contact sObject to the list
            updatedList.add(con);
            mapWithContacts.put(con.Id, con);
        }

        // Call update on the list contacts.
        //This results in one DML call for the entire list.
        Database.SaveResult[] saveresults = database.update(mapWithContacts.values(), true);
    }
}
