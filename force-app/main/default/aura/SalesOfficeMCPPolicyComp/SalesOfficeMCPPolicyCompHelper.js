({
	createMCPPolicyDataTableHeaders : function(component){
        var columns = [];
        columns.push({label: 'Policy', fieldName: 'Name', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Effective Date', fieldName: 'Effective_Date__c', type: 'date', sortable:true, editable: false, typeAttributes:{year:"numeric",month:"numeric",day:"numeric",timeZone:"UTC"} });
        columns.push({label: 'Policy Type', fieldName: 'Type__c', type: 'text', sortable:true, editable: false });
        component.set("v.policyColumns",columns);
        let selectedPolicy = component.get("v.selectedPolicy");
        var selectedRowIds = [];
        if(selectedPolicy != null && selectedPolicy != undefined && selectedPolicy.length > 0){
            selectedRowIds.push(selectedPolicy[0].Id);
        }
        let mcppolicytable = component.find("mcppolicytable");
        mcppolicytable.set("v.selectedRows", selectedRowIds);
    },
    createQuoteDataTableHeaders : function(component){
        var columns = [];
        columns.push({label: 'State', fieldName: 'State_Name__c', type: 'text', sortable:false, editable: false });
        columns.push({label: '# of Employees', fieldName: 'Total_of_Employees__c', type: 'number', sortable:false, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Gross Wages', fieldName: 'Total_Gross_Wages__c', type: 'currency', sortable:false, editable: false, cellAttributes: { alignment: 'left' } });
        component.set('v.quoteColumns', columns);
    },
})