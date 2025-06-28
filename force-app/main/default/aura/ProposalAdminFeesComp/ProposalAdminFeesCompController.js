({
	doInit : function(component, event, helper) {
		helper.handleInitilize(component, event);
	},
    
    handleShowEditAdminModal : function(component, event, helper) {
        helper.fetchAdministrativeFeeTypePickValues(component, event);
        helper.fetchDeliveryFeePerLocationPickValues(component, event);
        helper.fetchPerCheckFrequencyPickValues(component, event);
		component.set("v.isShowAdminFeesModal", true);
	},
    
    handleCloseEditAdminModal : function(component, event, helper) {
		component.set("v.isShowAdminFeesModal", false);
        helper.navigateToRecord(component, event, component.get("v.recordId"));
	},
    
    handleSaveEditAdminModal : function(component, event, helper) {
        let isValidated = helper.validateForm(component, 'adminFeeType,Admin_Fee_Gross_Wages,perCheckFrequency,Admin_Fee_Per_Check,Admin_Fee_Annual,deliverFeePerLocation,Delivery_Fee,Security_Deposit,Client_Set_up_Fee,Employee_New_Hire_Fee_Per_Employee,EPLI_50_000_Deductible,Worker_s_Compensation_Claims_Fee_Max,Worker_s_Compensation_Claims_Fee_Deposit,Employment_Practice_Liability_Insurance,EPLI_Maximum_Coverage_Limit_Per_Claim,Replacement_Check_Fee,NSF_Check_or_Reversed_ACH_Fee');
        if(isValidated){
            helper.updatePoropaslValues(component, event);
        }else{
            helper.doShowToast(component, 'Error', 'Please fill all required infromation and try again.', 'error');
        }
	},
})