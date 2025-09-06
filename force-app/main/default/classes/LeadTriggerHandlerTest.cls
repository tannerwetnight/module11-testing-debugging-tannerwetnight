@IsTest
public with sharing class LeadTriggerHandlerTest {
    @IsTest
    public static void testHandleTitleNormalization() {
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(FirstName = 'Jalen', LastName = 'Hurts', Title = 'vp', Company = 'EVI')); 
        leads.add(new Lead(FirstName = 'Jammar', LastName = 'Chase', Title = 'head of department', Company = 'EVI'));
        leads.add(new Lead(FirstName = 'Drake', LastName = 'London', Title = 'exec', Company = 'EVI'));
        leads.add(new Lead(FirstName = 'Brock', LastName = 'Bowers', Title = 'assist', Company = 'EVI'));

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);
        Test.stopTest();

        Lead updatedLead = leads[0];
        
        Assert.areEqual('Vice President',updatedLead.Title, 'The Title of this Lead should be "Vice President"');
        Assert.areEqual('Manager',leads[1].Title, 'The Title of this Lead should be "Manager"');
        Assert.areEqual('Executive',leads[2].Title, 'The Title of this Lead should be "Executive"');
        Assert.areEqual('Assistant',leads[3].Title, 'The Title of this Lead should be "Assistant"');
    }
    @testSetup 
    static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id, Email = 'test@gmail.com');
        insert con;
        List<Lead> leads = new List<Lead>();
        Integer numOfLeads = 400;
        for( Integer i = 0; i < numOfLeads; i++) {
            leads.add(new Lead(FirstName = 'Jalen' + i, LastName = 'Hurts' + i, Title = 'vp' + i , Company = 'EVI' + i));  
        }
        insert leads;        

        Lead convertibleLead = new Lead( FirstName = 'Convert', LastName = 'Me', Company = 'EVI', Email = 'test@gmail.com');
        insert convertibleLead;

        Lead nonConvertibleLead = new Lead( FirstName = 'Dont', LastName = 'Convert', Company = 'EVI', Email = 'dontconvert@gmail.com');
        insert nonConvertibleLead;
    }
    @IsTest
    public static void testHandleAutoLeadScoring() {
        List<Lead> leads = [SELECT Id, FirstName, LastName, Title, LeadSource, Lead_Score__c, Company, Email, Phone, Industry
                            FROM Lead];

        Lead firstLead = leads[0];

        for (Lead lead : leads) {
            Integer num = 0;

            if (Math.mod( num, 4) == 0) {
                lead.FirstName = '3';
                lead.LeadSource = 'Website';
                lead.Email = 'test@gmail.com';
            } else if (Math.mod( num, 4) == 1) {
                lead.FirstName = '5';
                lead.Phone = '1234567890';
            } else if (Math.mod( num, 4) == 2){
                lead.FirstName = '10';
                lead.Industry = 'Technology';
            } else if (Math.mod( num, 4) == 3){
                lead.FirstName = '18';
                lead.LeadSource = 'Website';
                lead.Email = 'test@gmail.com';
                lead.Phone = '1234567890';
                lead.Industry = 'Technology';
            }

            num++;
        }
        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);//I spent way too much time wondering why this wasnt passing. The whole time I had LeadTriggerHandler.handleTitleNormalization... sigh
        Test.stopTest();
        for (Lead lead : leads) {
			Assert.areEqual( Integer.valueOf(lead.FirstName), lead.Lead_Score__c, 'The lead score is incorrect');
        }
    }
    @IsTest
    public static void testHandleLeadAutoConvert() {
        Lead lead = new Lead(FirstName = 'Jalen', LastName = 'Hurts', Title = 'vp', Company = 'EVI', Email = 'test@gmail.com');
        List<Lead> leads = new List<Lead>();
        leads.add(lead);


        Test.startTest();
        insert leads;
        LeadTriggerHandler.handleLeadAutoConvert(leads);
        Test.stopTest();

        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :lead.Id];
        
        Assert.isTrue( updatedLead.IsConverted, 'The lead did not convert');
    }
}
//test git push