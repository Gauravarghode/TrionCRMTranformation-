public class ClinetContactWrapper {
    @AuraEnabled public String firstName;
    @AuraEnabled public String lastName;
    @AuraEnabled public String titleRelationship;
    @AuraEnabled public String email;
    @AuraEnabled public String phone;
    @AuraEnabled public String mobilePhone;
    @AuraEnabled public Decimal ownership;
    @AuraEnabled public String selectedState;
    @AuraEnabled public Decimal payroll;
    @AuraEnabled public String selectedClientLocation;
    @AuraEnabled public String clientLocation;
    @AuraEnabled public String selectedStampCode;
    @AuraEnabled public String primaryContactLastName;
    @AuraEnabled public String primaryContactFirstName;
    @AuraEnabled public String primaryContactPhone;
    @AuraEnabled public String primaryContactTitle;
    @AuraEnabled public String primaryContactEmail;
    @AuraEnabled public String clientContactType;
    @AuraEnabled public Date birthdate;
    @AuraEnabled public String duties;
    @AuraEnabled public boolean isPrimary;
    @AuraEnabled public boolean isIncluded;
    @AuraEnabled public String clientContactId;
    
    public ClinetContactWrapper(){
        this.isPrimary = false;
        this.firstName = null;
        this.lastName = null;
        this.titleRelationship = null;
        this.email = null;
        this.phone = null;
        this.mobilePhone = null;
        this.ownership = null;
        this.selectedState = null;
        this.payroll = null;
        this.selectedClientLocation = null;
        this.selectedStampCode = null;
        this.primaryContactLastName = null;
        this.primaryContactFirstName = null;
        this.primaryContactPhone = null;
        this.primaryContactTitle = null;
        this.primaryContactEmail = null;
        this.clientContactType = null;
        this.isIncluded = false;
        this.clientLocation = null;
        this.birthdate = null;
        this.duties = null;
        this.clientContactId = null;
    }
    
}