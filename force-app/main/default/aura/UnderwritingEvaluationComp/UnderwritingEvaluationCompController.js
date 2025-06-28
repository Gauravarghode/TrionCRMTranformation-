({
	doInit : function(component, event, helper) {
		helper.handleInitilize(component, event);
	},
    
    toggleLossYearRecord  : function(component, event, helper) {
        var lstUnderwritingEvaluationWrapper = component.get("v.lstUnderwritingEvaluationWrapper");
        var index = event.getSource().get("v.value");
        lstUnderwritingEvaluationWrapper[index].isExpaned = !lstUnderwritingEvaluationWrapper[index].isExpaned;
        component.set("v.lstUnderwritingEvaluationWrapper", lstUnderwritingEvaluationWrapper);
    },
    
    handleShowDeleteLossYear : function(component, event, helper) {
        var underwritingWrapper = component.get("v.lstUnderwritingEvaluationWrapper");
        
        if(underwritingWrapper != null && underwritingWrapper != undefined && underwritingWrapper.length > 0){
            for(let i=0;i<underwritingWrapper.length;i++){
                underwritingWrapper[i].isExpaned = false;
                underwritingWrapper[i].isDelete = true;
            }
            component.set("v.lstUnderwritingEvaluationWrapper", underwritingWrapper);
            component.set("v.isShowDeleteLossYear", true);
        }else{
            helper.doShowToast(component, 'Error', 'No records available!', 'error');
        }
    },
    
    handleDeleteLossYear : function(component, event, helper) {
        var underwritingWrapper = component.get("v.lstUnderwritingEvaluationWrapper");
        var isRecordSelected = false;
        
        if(underwritingWrapper != null && underwritingWrapper != undefined && underwritingWrapper.length > 0){
            for(let i=0;i<underwritingWrapper.length;i++){
                if(underwritingWrapper[i].isSelected){
                    isRecordSelected = true;
                    break;
                }
            }
        }
        
        if(isRecordSelected){
            helper.deleteLossYearHelper(component, event);
        }else{
            helper.doShowToast(component, 'Error', 'Please select atleast one record to delete', 'error');
        }
    },
    
    handleCancelDeleteLossYear : function(component, event, helper) {
         var underwritingWrapper = component.get("v.lstUnderwritingEvaluationWrapper");
        
        if(underwritingWrapper != null && underwritingWrapper != undefined && underwritingWrapper.length > 0){
            for(let i=0;i<underwritingWrapper.length;i++){
                underwritingWrapper[i].isExpaned = false;
                underwritingWrapper[i].isDelete = false;
                underwritingWrapper[i].isSelected = false;
            }
            component.set("v.lstUnderwritingEvaluationWrapper", underwritingWrapper);
            component.set("v.isShowDeleteLossYear", false);
        }
    },
    
    handleEvalutionEdit : function(component, event, helper){
        let index = event.currentTarget.dataset.index;
        let parentIndex = event.currentTarget.getAttribute("data-parentIndex");
        let eveId = event.currentTarget.getAttribute("data-eveId");
        let eveName = event.currentTarget.getAttribute("data-eveName");
        component.set("v.isShowEvalutionEditModal", true);
        component.set("v.selectedRecordId", eveId);
        component.set("v.selectRecordName", eveName);
        component.set("v.parentIndex", parentIndex);
    },
    
    handleCancelEvalution : function(component, event, helper){
        component.set("v.isShowEvalutionEditModal", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectRecordName", null);
        component.set("v.parentIndex", null);  
    },
    
    handleEvalutionDelete : function(component, event, helper){
        let index = event.currentTarget.dataset.index;
        let parentIndex = event.currentTarget.getAttribute("data-parentIndex");
        let eveId = event.currentTarget.getAttribute("data-eveId");
        helper.deleteLossYearEveHelper(component, event, eveId, parentIndex);
    },
    
    handleSuccessLossYearRecord : function(component, event, helper){
        component.set("v.isShowEvalutionEditModal", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectRecordName", null);
        helper.doShowToast(component, 'Success', 'Record updated successfully!', 'success');
        helper.handleInitilize(component, event);
    },
    
    handleErrorLossYearRecord : function(component, event, helper){
        helper.hideSpinner(component);
        var message = event.getParam('message');
        if(message != null && message != '' && message != undefined){
            helper.doShowToast(component, 'Error', message, 'error');
        }
    },
    
    handleEditEvalutionRecord : function(component, event, helper){
        //component.find("editForm").submit();
        let Excluded_Losses = component.find("Excluded_Losses_edit").get("v.value");
        let UW_Excluded_Loss_Comments = component.find("UW_Excluded_Loss_Comments_edit").get("v.value");
        let isUWExcludedLossCommentsRequired = false; 
        
        if(Excluded_Losses != null 
           && Excluded_Losses != undefined 
           && Excluded_Losses > 0
           &&(UW_Excluded_Loss_Comments == null 
              || UW_Excluded_Loss_Comments == undefined 
              || UW_Excluded_Loss_Comments == '')){
            isUWExcludedLossCommentsRequired = true;
        }    
        if(isUWExcludedLossCommentsRequired){
            let msg = 'UW Excluded Loss Comments : You must enter a value.';
            helper.doShowToast(component, 'Error', msg, 'error');
        }else{
            component.find("editForm").submit();
        }
    },
    
    
    handleCancelUpdateLossYear: function(component, event, helper){
        component.set("v.parentIndex", null);  
        component.set("v.isShowUpdateLossYearModal", false);  
    },
    
    handleUpdateLossYear: function(component, event, helper){
        var selectedYear = component.get("v.selectedYear");
        if(selectedYear != null && selectedYear != undefined && selectedYear != ''){
            var selectedRows = component.get("v.selectedRows");
            if(selectedRows != null && selectedRows != undefined && selectedRows.length > 0){
                helper.updateEvaluationYear(component, event);
            }else{
                helper.doShowToast(component, 'Error', 'Please select atleast one record to continue and try again.', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Year: You must select a value.', 'error');
        }
    },
    
    handleColumnSorting: function(component, event, helper){
        let fieldName = event.getParam("fieldName");
        component.set("v.sortedBy", fieldName);
    	component.set("v.sortedDirection", event.getParam("sortDirection")); 
        helper.sortData(component, fieldName, event.getParam("sortDirection"));
    },
    
    handleRowSelection: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows'); 
        component.set("v.selectedRows", selectedRows);
    },
    
    handleShowAddLossYearModal: function(component, event, helper){
        let index = event.currentTarget.dataset.index;
        component.set("v.parentIndex", index);  
		component.set("v.isShowAddLossYearModal", true);
        
        var underwritingWrapper = component.get("v.lstUnderwritingEvaluationWrapper");
        
        if(underwritingWrapper != null && underwritingWrapper != undefined && underwritingWrapper.length > 0){
            for(let i=0;i<underwritingWrapper.length;i++){
                if(i == index){
                    component.set("v.selectedYear", underwritingWrapper[i].oLossYear.Program_Year__c);
                }
            }
        }
        
        helper.fetchYears(component, event);
    },
    
    handleHideAddLossYearModal: function(component, event, helper){
		component.set("v.isShowAddLossYearModal", false);
        component.set("v.parentIndex", null); 
        component.set("v.selectedYear", null);
    },
    
    handleCreateEvalutionRecord: function(component, event, helper){
        let isValidForm = true;
        
        let selectedYear = component.get("v.selectedYear");
        let Policy_Start_Date = component.find("Policy_Start_Date").get("v.value");
        let Policy_End_Date = component.find("Policy_End_Date").get("v.value");
        let of_Claims = component.find("of_Claims").get("v.value");
        let Total_Reserves = component.find("Total_Reserves").get("v.value");
        let Total_Paid = component.find("Total_Paid").get("v.value");
        let LDF = component.find("LDF").get("v.value");
        let Valued = component.find("Valued").get("v.value");
        let Excluded_Losses = component.find("Excluded_Losses").get("v.value");
        let UW_Excluded_Loss_Comments = component.find("UW_Excluded_Loss_Comments").get("v.value");
        
        let isUWExcludedLossCommentsRequired = false;
        
        if(selectedYear == null || selectedYear == undefined || selectedYear == ''){
            isValidForm = false;
        }else if(Policy_Start_Date == null || Policy_Start_Date == undefined || Policy_Start_Date == ''){
            isValidForm = false;
        }else if(Policy_End_Date == null || Policy_End_Date == undefined || Policy_End_Date == ''){
            isValidForm = false;
        }else if(of_Claims == null || of_Claims == undefined || of_Claims == ''){
            isValidForm = false;
        }else if(Total_Reserves == null || Total_Reserves == undefined || Total_Reserves == ''){
            isValidForm = false;
        }else if(Total_Paid == null || Total_Paid == undefined || Total_Paid == ''){
            isValidForm = false;
        }else if(LDF == null || LDF == undefined || LDF == ''){
            isValidForm = false;
        }else if(Valued == null || Valued == undefined || Valued == ''){
            isValidForm = false;
        }else if(Excluded_Losses != null && Excluded_Losses != undefined && Excluded_Losses > 0 &&(UW_Excluded_Loss_Comments == null || UW_Excluded_Loss_Comments == undefined || UW_Excluded_Loss_Comments == '')){
            isValidForm = false;
            isUWExcludedLossCommentsRequired = true;
        }         
        
        if(isValidForm){
            var fields = {'sobjecttype':'Loss_Year_Evaluation__c'};
            fields['Policy_Start_Date__c'] = component.find("Policy_Start_Date").get("v.value");
            fields['Policy_End_Date__c'] = component.find("Policy_End_Date").get("v.value");
            fields['of_Claims__c'] = component.find("of_Claims").get("v.value");
            fields['Total_Reserves__c'] = component.find("Total_Reserves").get("v.value");
            fields['Total_Paid__c'] = component.find("Total_Paid").get("v.value");
            fields['LDF__c'] = component.find("LDF").get("v.value");
            fields['Valued__c'] = component.find("Valued").get("v.value");
            fields['Carrier__c'] = component.find("Carrier").get("v.value");
            fields['Excluded_Losses__c'] = component.find("Excluded_Losses").get("v.value");
            fields['UW_Excluded_Loss_Comments__c'] = component.find("UW_Excluded_Loss_Comments").get("v.value");
			helper.createLossYearEvaluationRecord(component, event, fields);
        }else{
            let msg = (isUWExcludedLossCommentsRequired?'UW Excluded Loss Comments : You must enter a value.':'Please fill all required information and try again');
            helper.doShowToast(component, 'Error', msg, 'error');
        }
    },
    
    handleSuccessCreateLossYearRecord: function(component, event, helper){
        component.set("v.isShowAddLossYearModal", false);
        helper.doShowToast(component, 'Success', 'Record created successfully!', 'success');
        helper.handleInitilize(component, event);
    },
    
    handleErrorCreateLossYearRecord: function(component, event, helper){
        helper.hideSpinner(component);
        var message = event.getParam('message');
        if(message != null && message != '' && message != undefined){
            helper.doShowToast(component, 'Error', message, 'error');
        }
    },
    
    handleShowNewLossYearModal: function(component, event, helper){
        component.set("v.isShowAddLossModal", true);
        component.set("v.selectedYear", null);
        component.set("v.mapYear", []);
        helper.fetchYears(component, event);
    },
    
    handleCloseNewLossYearModal: function(component, event, helper){
        component.set("v.isShowAddLossModal", false);
        component.set("v.selectedYear", null);
        component.set("v.mapYear", []);
    },
    
    handleCreateLoosYearEvalutionRecord: function(component, event, helper){
        let isValidForm = true;
        
        let selectedYear = component.get("v.selectedYear");
        let Policy_Start_Date = component.find("Policy_Start_Date").get("v.value");
        let Policy_End_Date = component.find("Policy_End_Date").get("v.value");
        let of_Claims = component.find("of_Claims").get("v.value");
        let Total_Reserves = component.find("Total_Reserves").get("v.value");
        let Total_Paid = component.find("Total_Paid").get("v.value");
        let LDF = component.find("LDF").get("v.value");
        let Valued = component.find("Valued").get("v.value");
        let Excluded_Losses_new = component.find("Excluded_Losses_new").get("v.value");
        let UW_Excluded_Loss_Comments_new = component.find("UW_Excluded_Loss_Comments_new").get("v.value");
        
        let isUW_Excluded_Loss_Comments_new = false;
        
        if(selectedYear == null || selectedYear == undefined || selectedYear == ''){
            isValidForm = false;
        }else if(Policy_Start_Date == null || Policy_Start_Date == undefined || Policy_Start_Date == ''){
            isValidForm = false;
        }else if(Policy_End_Date == null || Policy_End_Date == undefined || Policy_End_Date == ''){
            isValidForm = false;
        }else if(of_Claims == null || of_Claims == undefined || of_Claims == ''){
            isValidForm = false;
        }else if(Total_Reserves == null || Total_Reserves == undefined || Total_Reserves == ''){
            isValidForm = false;
        }else if(Total_Paid == null || Total_Paid == undefined || Total_Paid == ''){
            isValidForm = false;
        }else if(LDF == null || LDF == undefined || LDF == ''){
            isValidForm = false;
        }else if(Valued == null || Valued == undefined || Valued == ''){
            isValidForm = false;
        }else if(Excluded_Losses_new != null 
                 && Excluded_Losses_new != undefined 
                 && Excluded_Losses_new > 0
                 &&(UW_Excluded_Loss_Comments_new == null
                   || UW_Excluded_Loss_Comments_new == ''
                   || UW_Excluded_Loss_Comments_new == undefined)){
            isUW_Excluded_Loss_Comments_new = true;
            isValidForm = false;
        }        
        
        if(isValidForm){
            var fields = {'sobjecttype':'Loss_Year_Evaluation__c'};
            fields['Policy_Start_Date__c'] = component.find("Policy_Start_Date").get("v.value");
            fields['Policy_End_Date__c'] = component.find("Policy_End_Date").get("v.value");
            fields['of_Claims__c'] = component.find("of_Claims").get("v.value");
            fields['Total_Reserves__c'] = component.find("Total_Reserves").get("v.value");
            fields['Total_Paid__c'] = component.find("Total_Paid").get("v.value");
            fields['LDF__c'] = component.find("LDF").get("v.value");
            fields['Valued__c'] = component.find("Valued").get("v.value");
            fields['Carrier__c'] = component.find("Carrier").get("v.value");
            fields['Excluded_Losses__c'] = component.find("Excluded_Losses_new").get("v.value");
            fields['UW_Excluded_Loss_Comments__c'] = component.find("UW_Excluded_Loss_Comments_new").get("v.value");
			helper.createLossYearEvaluationRecord(component, event, fields);
        }else{
            let msg = (isUW_Excluded_Loss_Comments_new?'UW Excluded Loss Comments: You must enter a value':'Please fill all required information and try again');
            helper.doShowToast(component, 'Error', msg, 'error');
        }
    },
    
    handleDeleteParentLossYear: function(component, event, helper){
        let index = event.currentTarget.dataset.index;
        var underwritingWrapper = component.get("v.lstUnderwritingEvaluationWrapper");
        
        let lossYearId;
        
        if(underwritingWrapper != null && underwritingWrapper != undefined && underwritingWrapper.length > 0){
            for(let i=0;i<underwritingWrapper.length;i++){
                if(i == index){
                    lossYearId = underwritingWrapper[i].oLossYear.Id;
                }
            }
        }
        
        if(lossYearId != null && lossYearId != undefined){
            helper.deleteParentLossYearRecord(component, event, lossYearId);
        }
    },
    
})