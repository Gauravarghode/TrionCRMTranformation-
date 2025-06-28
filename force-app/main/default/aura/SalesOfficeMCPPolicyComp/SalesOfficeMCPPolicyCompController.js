({
	doInit : function(component, event, helper) {
		helper.createMCPPolicyDataTableHeaders(component);
        helper.createQuoteDataTableHeaders(component);
	},
    
    updateSelectedPolicy : function(component, event, helper) {
		var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedPolicy', selectedRows);
	}
})