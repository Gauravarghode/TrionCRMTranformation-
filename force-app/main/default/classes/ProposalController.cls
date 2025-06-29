/**
* @File Name : ProposalController .cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 26, 2025 |   | Initial Version
**/

public with sharing class ProposalController {

    @AuraEnabled
    public static List<Shell__c> getShellsByOpportunity(Id opportunityId) {
        Opportunity opp = [
            SELECT Id, AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1
        ];

        return [
            SELECT Id, Name
            FROM Shell__c
            WHERE Account__c = :opp.AccountId
        ];
    }
    
    @AuraEnabled
    public static void createProposals(Id opportunityId, Integer numberOfProposals) {
        List<Proposal__c> proposals = new List<Proposal__c>();

        for (Integer i = 0; i < numberOfProposals; i++) {
            Proposal__c proposal = new Proposal__c();
            proposal.Opportunity__c = opportunityId; // assuming this is the lookup
            proposals.add(proposal);
        }

        if (!proposals.isEmpty()) {
            insert proposals;
        }
    }
}