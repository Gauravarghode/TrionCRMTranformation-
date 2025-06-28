public class CreateCMS {
    public static void insertCMS(List<Campaign> listOfCampaignsinserted){
        
        
        List<CampaignMemberStatus> insertCMS = NEW List<CampaignMemberStatus>();
        CampaignMemberStatus createCMSNEW = new CampaignMemberStatus();       
        
        CampaignMemberStatus createCMSSoft = new CampaignMemberStatus();
        CampaignMemberStatus createCMSHARD = new CampaignMemberStatus();
        CampaignMemberStatus createCMSINTER = new CampaignMemberStatus();
        CampaignMemberStatus createCMSUNSUB = new CampaignMemberStatus();
        CampaignMemberStatus createCMSOPEND = new CampaignMemberStatus();
        for(Campaign camp:listOfCampaignsinserted ){
           
            createCMSNEW.CampaignId = camp.id;
            createCMSSoft.CampaignId =camp.id;
            createCMSHARD.CampaignId =camp.id;
            createCMSINTER.CampaignId =camp.id;
            createCMSUNSUB.CampaignId =camp.id;
            createCMSOPEND.CampaignId = camp.id;
            
            createCMSNEW.label = 'New';
            createCMSNEW.IsDefault = true;
            createCMSSoft.Label = 'Softbounced';
            createCMSHARD.Label = 'Hardbounced';
            createCMSINTER.Label = 'Interacted'; 
            createCMSUNSUB.Label = 'Unsubscribed';
            createCMSOPEND.Label = 'Opened';
            
            insertCMS.add(createCMSNEW);
            insertCMS.add(createCMSSoft);
            insertCMS.add(createCMSHARD);
            insertCMS.add(createCMSINTER);
            insertCMS.add(createCMSUNSUB);
            insertCMS.add(createCMSOPEND);
            
            
            
        }
        insert insertCMS; 
        
    }
    
}