({
	doInit : function(component, event, helper) {
		helper.handleInitlization(component, event);
	},
    
    handleColumnSorting : function(component, event, helper) {
        let fieldName = event.getParam("fieldName");
        component.set("v.sortedBy", fieldName);
    	component.set("v.sortedDirection", event.getParam("sortDirection")); 
        helper.sortData(component, fieldName, event.getParam("sortDirection"));
    },
    
    handleRowSelection : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        component.set("v.selectedRows", selectedRows);
    },
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view':
                component.set("v.oSubmissionRequirement", row);
                //component.set("v.isShowViewModal", true);
            	helper.fetchContentDocumentId(component, event);
                break;
                
            case 'delete':
                component.set("v.oSubmissionRequirement", row);
                helper.deleteFileUpdateSubmissionRequirement(component, event);
                break;
                
            case 'edit':
                component.set("v.oSubmissionRequirement", row);
                if(row.Requirement_Type__c != null && row.Requirement_Type__c != undefined && row.Requirement_Type__c == 'ACORD'){
                    component.set("v.isShowUploadModal", true);
                    component.set("v.selectedRecordId", row.Id);
                    component.set("v.submissionRequirementNotes", row.Notes__c);
                    component.set("v.natureofBusinessDescription", row.Nature_of_Business_Description__c);
                    
                    helper.getWCRateRecords(component,event);
                    helper.fetchPicklistValues(component, event, 'Submission_Requirement__c', 'ACORD_Type__c', row.ACORD_Type__c);
                    helper.createWCRateDataTableHeaders(component);
                    helper.fetchShowCongaButtons(component, event, row.Id);
                }else{
                    helper.doShowToast(component, 'Error', 'You don\'t have permission to edit this record', 'error');
                }
                break;
                
                case 'Accord_Signature_Request':
                helper.fetchAccordSignatureRequestURL(component,event,row.Id);
                break;
                
                case 'Generate_ACORD':
                helper.fetchGenerateACORD(component,event,row.Id);
                break;
        }
    },
    
    handleOnchange : function(component, event, helper){
        let selectedRequirementType = component.get("v.SelectedRequirementTypeId");
        let submissionRequirement = component.get("v.lstSubmissionRequirement");
        if(selectedRequirementType != null && selectedRequirementType != undefined){
            for(var i = 0; i<submissionRequirement.length; i++){
                if(submissionRequirement[i].Id === selectedRequirementType){
                    /*if(submissionRequirement[i].Status__c != null
                       && submissionRequirement[i].Status__c != undefined
                       && submissionRequirement[i].Status__c == 'Submitted'){*/
                        component.set("v.oSubmissionRequirement", submissionRequirement[i]);
                        component.set("v.isTrue", false);
                        component.set("v.isFileUploaded", false);
                        component.set("v.isShowAddNote", false);
                        
                        if(submissionRequirement[i].Requirement_Type__c != null 
                           && submissionRequirement[i].Requirement_Type__c != undefined 
                           && submissionRequirement[i].Requirement_Type__c == 'ACORD'){
                            helper.getWCRateRecords(component,event);
                            helper.createWCRateDataTableHeaders(component);
                            helper.fetchPicklistValues(component, event, 'Submission_Requirement__c', 'ACORD_Type__c', submissionRequirement[i].ACORD_Type__c);
                        }
                    /*}else{
                        //helper.doShowToast(component, 'Error', 'This Requirement is submitted, please select other Requirement and continue.', 'error');
                        helper.doShowToast(component, 'Error', 'This Requirement is not submitted, please select other Requirement and continue.', 'error');
                    }*/
                }
            }
            
        }else{
            helper.doShowToast(component, 'Error', 'Please select atleast one record to continue', 'error');
        }
        
    },
    
    handleUploadDocument : function(component, event, helper) {
        component.set("v.isShowUploadModal", true);
        component.set("v.isTrue", true);
        component.set("v.SelectedRequirementTypeId", null);
    },
    
    /*handleViewDocument : function(component, event, helper) {
        let selectedRows = component.get("v.selectedRows");
        if(selectedRows != null && selectedRows != undefined && selectedRows.length >0){
            component.set("v.oSubmissionRequirement", selectedRows[0]);
            component.set("v.isShowViewModal", true);
            helper.fetchContentDocumentId(component, event);
        }else{
            helper.doShowToast(component, 'Error', 'Please select atleast one record to continue', 'error');
        }
    },*/
    
    handleModalViewDocument : function(component, event, helper) {
        var contentDocumentId = component.get("v.contentDocumentId");
        if(contentDocumentId != null && contentDocumentId != undefined){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.contentDocumentId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
        }else{
            helper.doShowToast(component, 'Error', 'No Document to view', 'error');
        }
    },
    
    handleDeleteViewDocument : function(component, event, helper) {
        var contentDocumentId = component.get("v.contentDocumentId");
        if(contentDocumentId != null && contentDocumentId != undefined){
        	helper.deleteFileUpdateSubmissionRequirement(component, event);    
        }else{
            helper.doShowToast(component, 'Error', 'No Document to delete', 'error');
        }
    },
    
    handleHideUploadModal : function(component, event, helper) {
        component.set("v.isShowUploadModal", false);
         component.set("v.isShowAccordSignatureRequestButton", false);
        component.set("v.isShowGenerateACORDButton", false);
        component.set("v.isFileUploaded", false);
        component.set("v.isShowAddNote", false);
        component.set("v.isTrue", false);
        component.set("v.oSubmissionRequirement", null);
        component.set("v.submissionRequirementNotes", null);
        component.set("v.selectedRows", null);
        component.find("submissionTable").set("v.selectedRows", []);
        component.set("v.selectedRecordId", null);
        component.set("v.SelectedRequirementTypeId", null);
        component.set("v.natureofBusinessDescription", null);
        helper.handleInitlization(component, event);
        helper.navigateToRecord(component, event, component.get("v.recordId"));
    },
    
    handleHideViewModal : function(component, event, helper) {
        component.set("v.isShowViewModal", false);
        component.set("v.oSubmissionRequirement", null);
        component.set("v.contentDocumentId", null);
        helper.handleInitlization(component, event);
    },
    
    handleUploadFinished : function(component, event, helper) {
        component.set("v.isFileUploaded", true);
        
        var uploadedFiles = event.getParam("files");
        
        let message = 'File uploaded successfully';
        
        if(uploadedFiles.length > 1){
            message = 'Files uploaded successfully';
        }
        
        helper.doShowToast(component, 'Success', message, 'success');
    },
    
    
    handleUploadFinish : function(component, event, helper){
        let isFileUploaded = component.get("v.isFileUploaded");
        
        let requirementType = component.get("v.oSubmissionRequirement.Requirement_Type__c");
        
        if(requirementType != null && requirementType != undefined && requirementType == 'ACORD'){

            //let isFormValidated = helper.validateForm(component, 'OWN_OPERATE_LEASE_AIRCRAFT_WATERCRAFT ,DISCONTINUED_OPERATIONS_HAZARDOUS_MATER ,WORK_PERFORMED_UNDERGROUND_OR_ABOVE_15_F ,WORK_PERFORMED_ON_BARGES_VESSELS_DOCKS ,ENGAGED_IN_ANY_OTHER_TYPE_OF_BUSINESS ,SUB_CONTRACTORS_USED ,WORK_SUBLET_W_O_CERTIFICATES_OF_INSURANC ,WRITTEN_SAFETY_PROGRAM_IN_OPERATION ,GROUP_TRANSPORTATION_PROVIDED ,EMPLOYEES_UNDER_16_OR_OVER_60_YEARS_OF_A ,SEASONAL_EMPLOYEES ,VOLUNTEER_OR_DONATED_LABOR ,EMPLOYEES_WITH_PHYSICAL_HANDICAPS ,EMPLOYEES_TRAVEL_OUT_OF_STATE ,Indicate_state_s_of_travel_and_frequenc ,ATHLETIC_TEAMS_SPONSORED ,PHYSICALS_REQUIRED_AFTER_OFFERS_OF_EMPLO ,ANY_OTHER_INSURANCE_WITH_THIS_INSURER ,COVERAGE_DEC_CANC_NON_RENEWED_IN_LAST_3 ,EMPLOYEE_HEALTH_PLANS_PROVIDED ,EMPLOYEES_PERFORM_WORK_FOR_OTHER_BUSINES ,LEASE_EMPLOYEES_TO_OR_FROM_OTHER_EMPLOYE ,EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME ,TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS ,UNDISPUTED_UNPAID_WC_PREMIUM_DUE');
            let isFormValidated = true;
            let selectedACORDType = component.get("v.selectedAcordtype");
            if(selectedACORDType != null && selectedACORDType != undefined && selectedACORDType != ''){
                if(/*isFileUploaded ||*/ isFormValidated){
                    /*if(isFileUploaded){
                        helper.submitSubmissionRequirements(component, event, true);
                    }else{*/
                        let submissionRequirementObj = {'sobjecttype':'Submission_Requirement__c'};
                        //proposalObj['Opportunity__c'] = component.get("v.opp.Id");
                        submissionRequirementObj['ACORD_Type__c'] = component.get("v.selectedAcordtype");
                        submissionRequirementObj['OWN_OPERATE_LEASE_AIRCRAFT_WATERCRAFT__c'] = component.find("OWN_OPERATE_LEASE_AIRCRAFT_WATERCRAFT").get("v.value");
                        submissionRequirementObj['DISCONTINUED_OPERATIONS_HAZARDOUS_MATER__c'] = component.find("DISCONTINUED_OPERATIONS_HAZARDOUS_MATER").get("v.value");
                        submissionRequirementObj['WORK_PERFORMED_UNDERGROUND_OR_ABOVE_15_F__c'] = component.find("WORK_PERFORMED_UNDERGROUND_OR_ABOVE_15_F").get("v.value");
                        submissionRequirementObj['WORK_PERFORMED_ON_BARGES_VESSELS_DOCKS__c'] = component.find("WORK_PERFORMED_ON_BARGES_VESSELS_DOCKS").get("v.value");
                        submissionRequirementObj['ENGAGED_IN_ANY_OTHER_TYPE_OF_BUSINESS__c'] = component.find("ENGAGED_IN_ANY_OTHER_TYPE_OF_BUSINESS").get("v.value");
                        submissionRequirementObj['SUB_CONTRACTORS_USED__c'] = component.find("SUB_CONTRACTORS_USED").get("v.value");
                        submissionRequirementObj['WORK_SUBLET_W_O_CERTIFICATES_OF_INSURANC__c'] = component.find("WORK_SUBLET_W_O_CERTIFICATES_OF_INSURANC").get("v.value");
                        submissionRequirementObj['WRITTEN_SAFETY_PROGRAM_IN_OPERATION__c'] = component.find("WRITTEN_SAFETY_PROGRAM_IN_OPERATION").get("v.value");
                        submissionRequirementObj['GROUP_TRANSPORTATION_PROVIDED__c'] = component.find("GROUP_TRANSPORTATION_PROVIDED").get("v.value");
                        submissionRequirementObj['EMPLOYEES_UNDER_16_OR_OVER_60_YEARS_OF_A__c'] = component.find("EMPLOYEES_UNDER_16_OR_OVER_60_YEARS_OF_A").get("v.value");
                        submissionRequirementObj['SEASONAL_EMPLOYEES__c'] = component.find("SEASONAL_EMPLOYEES").get("v.value");
                        submissionRequirementObj['VOLUNTEER_OR_DONATED_LABOR__c'] = component.find("VOLUNTEER_OR_DONATED_LABOR").get("v.value");
                        submissionRequirementObj['EMPLOYEES_WITH_PHYSICAL_HANDICAPS__c'] = component.find("EMPLOYEES_WITH_PHYSICAL_HANDICAPS").get("v.value");
                        submissionRequirementObj['EMPLOYEES_TRAVEL_OUT_OF_STATE__c'] = component.find("EMPLOYEES_TRAVEL_OUT_OF_STATE").get("v.value");
                        submissionRequirementObj['Indicate_state_s_of_travel_and_frequenc__c'] = component.find("Indicate_state_s_of_travel_and_frequenc").get("v.value");
                        submissionRequirementObj['ATHLETIC_TEAMS_SPONSORED__c'] = component.find("ATHLETIC_TEAMS_SPONSORED").get("v.value");
                        submissionRequirementObj['PHYSICALS_REQUIRED_AFTER_OFFERS_OF_EMPLO__c'] = component.find("PHYSICALS_REQUIRED_AFTER_OFFERS_OF_EMPLO").get("v.value");
                        submissionRequirementObj['ANY_OTHER_INSURANCE_WITH_THIS_INSURER__c'] = component.find("ANY_OTHER_INSURANCE_WITH_THIS_INSURER").get("v.value");
                        submissionRequirementObj['COVERAGE_DEC_CANC_NON_RENEWED_IN_LAST_3__c'] = component.find("COVERAGE_DEC_CANC_NON_RENEWED_IN_LAST_3").get("v.value");
                        submissionRequirementObj['EMPLOYEE_HEALTH_PLANS_PROVIDED__c'] = component.find("EMPLOYEE_HEALTH_PLANS_PROVIDED").get("v.value");
                        submissionRequirementObj['EMPLOYEES_PERFORM_WORK_FOR_OTHER_BUSINES__c'] = component.find("EMPLOYEES_PERFORM_WORK_FOR_OTHER_BUSINES").get("v.value");
                        submissionRequirementObj['LEASE_EMPLOYEES_TO_OR_FROM_OTHER_EMPLOYE__c'] = component.find("LEASE_EMPLOYEES_TO_OR_FROM_OTHER_EMPLOYE").get("v.value");
                        submissionRequirementObj['EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME__c'] = component.find("EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME").get("v.value");
                        submissionRequirementObj['TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS__c'] = component.find("TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS").get("v.value");
                        submissionRequirementObj['UNDISPUTED_UNPAID_WC_PREMIUM_DUE__c'] = component.find("UNDISPUTED_UNPAID_WC_PREMIUM_DUE").get("v.value");
                        submissionRequirementObj['Nature_of_Business_Description__c'] = component.get("v.natureofBusinessDescription");
                        submissionRequirementObj['EACH_ACCIDENT__c'] = component.get("v.oSubmissionRequirement.EACH_ACCIDENT__c");
                        submissionRequirementObj['DISEASE_POLICY_LIMIT__c'] = component.get("v.oSubmissionRequirement.DISEASE_POLICY_LIMIT__c");
                        submissionRequirementObj['DISEASE_EACH_EMPLOYEE__c'] = component.get("v.oSubmissionRequirement.DISEASE_EACH_EMPLOYEE__c");
                        submissionRequirementObj['U_S_L_H__c'] = component.get("v.oSubmissionRequirement.U_S_L_H__c");
                        submissionRequirementObj['VOLUNTARY_COMP__c'] = component.get("v.oSubmissionRequirement.VOLUNTARY_COMP__c");
                        submissionRequirementObj['FOREIGN_COV__c'] = component.get("v.oSubmissionRequirement.FOREIGN_COV__c");
                        submissionRequirementObj['MANAGED_CARE_OPTION__c'] = component.get("v.oSubmissionRequirement.MANAGED_CARE_OPTION__c");
                    	submissionRequirementObj['Notes__c'] = component.get("v.submissionRequirementNotes");
                        
                        if(component.find("of_work_subcontracted") != null && component.find("of_work_subcontracted") != undefined){
                            submissionRequirementObj['of_work_subcontracted__c'] = component.find("of_work_subcontracted").get("v.value");
                        }
                        
                        if(component.find("VOLUNTEER_OR_DONATED_LABOR_EXPLANATION") != null 
                           && component.find("VOLUNTEER_OR_DONATED_LABOR_EXPLANATION") != undefined){
                            submissionRequirementObj['VOLUNTEER_OR_DONATED_LABOR_EXPLANATION__c'] = component.find("VOLUNTEER_OR_DONATED_LABOR_EXPLANATION").get("v.value");
                        }
                        
                        if(component.find("of_Employees_work_from_home") != null && component.find("of_Employees_work_from_home") != undefined){
                            submissionRequirementObj['of_Employees_work_from_home__c'] = component.find("of_Employees_work_from_home").get("v.value");
                        }
                        
                        if(component.find("SPECIFY_TAX_LIENS_BANKRUPTCY") != null && component.find("SPECIFY_TAX_LIENS_BANKRUPTCY") != undefined){
                            submissionRequirementObj['SPECIFY_TAX_LIENS_BANKRUPTCY__c'] = component.find("SPECIFY_TAX_LIENS_BANKRUPTCY").get("v.value");
                        }
                        
                        if(component.find("EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM") != null 
                           && component.find("EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM") != undefined){
                            submissionRequirementObj['EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM__c'] = component.find("EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM").get("v.value");
                        }
                        
                        helper.createProposalSubmitSubmissionRequirement(component,event, submissionRequirementObj, true);
                    //}
                }else{
                    helper.doShowToast(component, 'Error', 'Please fill all required fields to continue', 'error');// upload atleast one file to continue or 
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select ACORD Type ', 'error');
            }
        }else{
            let submissionRequirementNotes = component.get("v.submissionRequirementNotes");
            if(isFileUploaded || (submissionRequirementNotes != null && submissionRequirementNotes != '' && submissionRequirementNotes != undefined)){
                helper.submitSubmissionRequirements(component, event, true);
            }else{
                helper.doShowToast(component, 'Error', 'Please upload atleast one file to continue or fill all required fields to continue', 'error');
            }
        }
    },
    
    handleSaveSubmissionDocument : function(component, event, helper){
        let isFileUploaded = component.get("v.isFileUploaded");
        let requirementType = component.get("v.oSubmissionRequirement.Requirement_Type__c");
        
        if(requirementType != null && requirementType != undefined && requirementType == 'ACORD'){
            let isFormValidated = helper.validateForm(component, 'OWN_OPERATE_LEASE_AIRCRAFT_WATERCRAFT ,DISCONTINUED_OPERATIONS_HAZARDOUS_MATER ,WORK_PERFORMED_UNDERGROUND_OR_ABOVE_15_F ,WORK_PERFORMED_ON_BARGES_VESSELS_DOCKS ,ENGAGED_IN_ANY_OTHER_TYPE_OF_BUSINESS ,SUB_CONTRACTORS_USED ,WORK_SUBLET_W_O_CERTIFICATES_OF_INSURANC ,WRITTEN_SAFETY_PROGRAM_IN_OPERATION ,GROUP_TRANSPORTATION_PROVIDED ,EMPLOYEES_UNDER_16_OR_OVER_60_YEARS_OF_A ,SEASONAL_EMPLOYEES ,VOLUNTEER_OR_DONATED_LABOR ,EMPLOYEES_WITH_PHYSICAL_HANDICAPS ,EMPLOYEES_TRAVEL_OUT_OF_STATE ,Indicate_state_s_of_travel_and_frequenc ,ATHLETIC_TEAMS_SPONSORED ,PHYSICALS_REQUIRED_AFTER_OFFERS_OF_EMPLO ,ANY_OTHER_INSURANCE_WITH_THIS_INSURER ,COVERAGE_DEC_CANC_NON_RENEWED_IN_LAST_3 ,EMPLOYEE_HEALTH_PLANS_PROVIDED ,EMPLOYEES_PERFORM_WORK_FOR_OTHER_BUSINES ,LEASE_EMPLOYEES_TO_OR_FROM_OTHER_EMPLOYE ,EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME ,TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS ,UNDISPUTED_UNPAID_WC_PREMIUM_DUE');
            let selectedACORDType = component.get("v.selectedAcordtype");
            if(selectedACORDType != null && selectedACORDType != undefined && selectedACORDType !='' ){
                if(isFileUploaded || isFormValidated){
                    if(isFileUploaded){
                        helper.submitSubmissionRequirements(component, event, false);
                    }else{
                        let submissionRequirementObj = {'sobjecttype':'Submission_Requirement__c'};
                        //proposalObj['Opportunity__c'] = component.get("v.opp.Id");
                        submissionRequirementObj['ACORD_Type__c'] = component.get("v.selectedAcordtype");
                        submissionRequirementObj['OWN_OPERATE_LEASE_AIRCRAFT_WATERCRAFT__c'] = component.find("OWN_OPERATE_LEASE_AIRCRAFT_WATERCRAFT").get("v.value");
                        submissionRequirementObj['DISCONTINUED_OPERATIONS_HAZARDOUS_MATER__c'] = component.find("DISCONTINUED_OPERATIONS_HAZARDOUS_MATER").get("v.value");
                        submissionRequirementObj['WORK_PERFORMED_UNDERGROUND_OR_ABOVE_15_F__c'] = component.find("WORK_PERFORMED_UNDERGROUND_OR_ABOVE_15_F").get("v.value");
                        submissionRequirementObj['WORK_PERFORMED_ON_BARGES_VESSELS_DOCKS__c'] = component.find("WORK_PERFORMED_ON_BARGES_VESSELS_DOCKS").get("v.value");
                        submissionRequirementObj['ENGAGED_IN_ANY_OTHER_TYPE_OF_BUSINESS__c'] = component.find("ENGAGED_IN_ANY_OTHER_TYPE_OF_BUSINESS").get("v.value");
                        submissionRequirementObj['SUB_CONTRACTORS_USED__c'] = component.find("SUB_CONTRACTORS_USED").get("v.value");
                        submissionRequirementObj['WORK_SUBLET_W_O_CERTIFICATES_OF_INSURANC__c'] = component.find("WORK_SUBLET_W_O_CERTIFICATES_OF_INSURANC").get("v.value");
                        submissionRequirementObj['WRITTEN_SAFETY_PROGRAM_IN_OPERATION__c'] = component.find("WRITTEN_SAFETY_PROGRAM_IN_OPERATION").get("v.value");
                        submissionRequirementObj['GROUP_TRANSPORTATION_PROVIDED__c'] = component.find("GROUP_TRANSPORTATION_PROVIDED").get("v.value");
                        submissionRequirementObj['EMPLOYEES_UNDER_16_OR_OVER_60_YEARS_OF_A__c'] = component.find("EMPLOYEES_UNDER_16_OR_OVER_60_YEARS_OF_A").get("v.value");
                        submissionRequirementObj['SEASONAL_EMPLOYEES__c'] = component.find("SEASONAL_EMPLOYEES").get("v.value");
                        submissionRequirementObj['VOLUNTEER_OR_DONATED_LABOR__c'] = component.find("VOLUNTEER_OR_DONATED_LABOR").get("v.value");
                        submissionRequirementObj['EMPLOYEES_WITH_PHYSICAL_HANDICAPS__c'] = component.find("EMPLOYEES_WITH_PHYSICAL_HANDICAPS").get("v.value");
                        submissionRequirementObj['EMPLOYEES_TRAVEL_OUT_OF_STATE__c'] = component.find("EMPLOYEES_TRAVEL_OUT_OF_STATE").get("v.value");
                        submissionRequirementObj['Indicate_state_s_of_travel_and_frequenc__c'] = component.find("Indicate_state_s_of_travel_and_frequenc").get("v.value");
                        submissionRequirementObj['ATHLETIC_TEAMS_SPONSORED__c'] = component.find("ATHLETIC_TEAMS_SPONSORED").get("v.value");
                        submissionRequirementObj['PHYSICALS_REQUIRED_AFTER_OFFERS_OF_EMPLO__c'] = component.find("PHYSICALS_REQUIRED_AFTER_OFFERS_OF_EMPLO").get("v.value");
                        submissionRequirementObj['ANY_OTHER_INSURANCE_WITH_THIS_INSURER__c'] = component.find("ANY_OTHER_INSURANCE_WITH_THIS_INSURER").get("v.value");
                        submissionRequirementObj['COVERAGE_DEC_CANC_NON_RENEWED_IN_LAST_3__c'] = component.find("COVERAGE_DEC_CANC_NON_RENEWED_IN_LAST_3").get("v.value");
                        submissionRequirementObj['EMPLOYEE_HEALTH_PLANS_PROVIDED__c'] = component.find("EMPLOYEE_HEALTH_PLANS_PROVIDED").get("v.value");
                        submissionRequirementObj['EMPLOYEES_PERFORM_WORK_FOR_OTHER_BUSINES__c'] = component.find("EMPLOYEES_PERFORM_WORK_FOR_OTHER_BUSINES").get("v.value");
                        submissionRequirementObj['LEASE_EMPLOYEES_TO_OR_FROM_OTHER_EMPLOYE__c'] = component.find("LEASE_EMPLOYEES_TO_OR_FROM_OTHER_EMPLOYE").get("v.value");
                        submissionRequirementObj['EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME__c'] = component.find("EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME").get("v.value");
                        submissionRequirementObj['TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS__c'] = component.find("TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS").get("v.value");
                        submissionRequirementObj['UNDISPUTED_UNPAID_WC_PREMIUM_DUE__c'] = component.find("UNDISPUTED_UNPAID_WC_PREMIUM_DUE").get("v.value");
                        submissionRequirementObj['Nature_of_Business_Description__c'] = component.get("v.natureofBusinessDescription");
                        submissionRequirementObj['EACH_ACCIDENT__c'] = component.get("v.oSubmissionRequirement.EACH_ACCIDENT__c");
                        submissionRequirementObj['DISEASE_POLICY_LIMIT__c'] = component.get("v.oSubmissionRequirement.DISEASE_POLICY_LIMIT__c");
                        submissionRequirementObj['DISEASE_EACH_EMPLOYEE__c'] = component.get("v.oSubmissionRequirement.DISEASE_EACH_EMPLOYEE__c");
                        submissionRequirementObj['U_S_L_H__c'] = component.get("v.oSubmissionRequirement.U_S_L_H__c");
                        submissionRequirementObj['VOLUNTARY_COMP__c'] = component.get("v.oSubmissionRequirement.VOLUNTARY_COMP__c");
                        submissionRequirementObj['FOREIGN_COV__c'] = component.get("v.oSubmissionRequirement.FOREIGN_COV__c");
                        submissionRequirementObj['MANAGED_CARE_OPTION__c'] = component.get("v.oSubmissionRequirement.MANAGED_CARE_OPTION__c");
                        
                        if(component.find("of_work_subcontracted") != null && component.find("of_work_subcontracted") != undefined){
                            submissionRequirementObj['of_work_subcontracted__c'] = component.find("of_work_subcontracted").get("v.value");
                        }
                        
                        if(component.find("VOLUNTEER_OR_DONATED_LABOR_EXPLANATION") != null 
                           && component.find("VOLUNTEER_OR_DONATED_LABOR_EXPLANATION") != undefined){
                            submissionRequirementObj['VOLUNTEER_OR_DONATED_LABOR_EXPLANATION__c'] = component.find("VOLUNTEER_OR_DONATED_LABOR_EXPLANATION").get("v.value");
                        }
                        
                        if(component.find("of_Employees_work_from_home") != null && component.find("of_Employees_work_from_home") != undefined){
                            submissionRequirementObj['of_Employees_work_from_home__c'] = component.find("of_Employees_work_from_home").get("v.value");
                        }
                        
                        if(component.find("SPECIFY_TAX_LIENS_BANKRUPTCY") != null && component.find("SPECIFY_TAX_LIENS_BANKRUPTCY") != undefined){
                            submissionRequirementObj['SPECIFY_TAX_LIENS_BANKRUPTCY__c'] = component.find("SPECIFY_TAX_LIENS_BANKRUPTCY").get("v.value");
                        }
                        
                        if(component.find("EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM") != null 
                           && component.find("EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM") != undefined){
                            submissionRequirementObj['EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM__c'] = component.find("EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM").get("v.value");
                        }
                        
                        helper.createProposalSubmitSubmissionRequirement(component,event, submissionRequirementObj, false);
                    }
                }else{
                    helper.doShowToast(component, 'Error', 'Please upload atleast one file to continue or fill all required fields to continue', 'error');
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select ACORD Type ', 'error');
            }
            
        }else{
            let submissionRequirementNotes = component.get("v.submissionRequirementNotes");
            if(isFileUploaded || (submissionRequirementNotes != null && submissionRequirementNotes != '' && submissionRequirementNotes != undefined)){
                helper.submitSubmissionRequirements(component, event, false);
            }else{
                helper.doShowToast(component, 'Error', 'Please upload atleast one file to continue or fill all required fields to continue', 'error');
            }
        }
    },
    
    handleChangeSUBCONTRACTORSUSED : function(component, event, helper){
        let isShowWorkSubContracted = false;
        let sub_CONTRACTORS_USED = event.getSource().get("v.value");
        if(sub_CONTRACTORS_USED != null && sub_CONTRACTORS_USED != undefined && sub_CONTRACTORS_USED == 'Y'){
            isShowWorkSubContracted = true;
        }
        component.set("v.isShowWorkSubContracted", isShowWorkSubContracted);
    },
    
    handleVOLUNTEERORDONATEDLABOR : function(component, event, helper){
        let isShowVOLUNTEER_OR_DONATED_LABOR_EXPLANATION = false;
        let VOLUNTEER_OR_DONATED_LABOR = event.getSource().get("v.value");
        if(VOLUNTEER_OR_DONATED_LABOR != null 
           && VOLUNTEER_OR_DONATED_LABOR != undefined 
           && VOLUNTEER_OR_DONATED_LABOR == 'Y'){
            isShowVOLUNTEER_OR_DONATED_LABOR_EXPLANATION = true;
        }
        component.set("v.isShowVOLUNTEER_OR_DONATED_LABOR_EXPLANATION", isShowVOLUNTEER_OR_DONATED_LABOR_EXPLANATION);
    },
    
    handleEMPLOYEESPREDOMINANTLYWORKATHOME : function(component, event, helper){
        let isShowEmployeesWorkFromHome = false;
        let EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME = event.getSource().get("v.value");
        if(EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME != null 
           && EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME != undefined 
           && EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME == 'Y'){
            isShowEmployeesWorkFromHome = true;
        }
        component.set("v.isShowEmployeesWorkFromHome", isShowEmployeesWorkFromHome);
    },
    
    handleTAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS : function(component, event, helper){
        let isShowSPECIFYTAXLIENSBANKRUPTCY = false;
        let TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS = event.getSource().get("v.value");
        if(TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS != null 
           && TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS != undefined 
           && TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS == 'Y'){
            isShowSPECIFYTAXLIENSBANKRUPTCY = true;
        }
        component.set("v.isShowSPECIFYTAXLIENSBANKRUPTCY", isShowSPECIFYTAXLIENSBANKRUPTCY);
    },
    
    handleUNDISPUTEDUNPAIDWCPREMIUMDUE : function(component, event, helper){
        let isShowEXPLAINUNDISPUTEDANDUNPAIDWCPREMIUM = false;
        let UNDISPUTED_UNPAID_WC_PREMIUM_DUE = event.getSource().get("v.value");
        if(UNDISPUTED_UNPAID_WC_PREMIUM_DUE != null 
           && UNDISPUTED_UNPAID_WC_PREMIUM_DUE != undefined 
           && UNDISPUTED_UNPAID_WC_PREMIUM_DUE == 'Y'){
            isShowEXPLAINUNDISPUTEDANDUNPAIDWCPREMIUM = true;
        }
        component.set("v.isShowEXPLAINUNDISPUTEDANDUNPAIDWCPREMIUM", isShowEXPLAINUNDISPUTEDANDUNPAIDWCPREMIUM);
    },
    
    handleWCRateColumnSorting : function(component, event, helper){
        let fieldName = event.getParam("fieldName");
        component.set("v.WCRateSortedBy", fieldName);
    	component.set("v.WCRateSortedDirection", event.getParam("sortDirection")); 
        helper.sortWCRateData(component, fieldName, event.getParam("sortDirection"));
    },
    
    handleWCRateRowAction : function(component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'edit':
                component.set("v.oWCRate", row);
                if(row.SUTA_Quote__r.State__c != null && row.SUTA_Quote__r.State__c != undefined){
                    var whereClause = ' State__c = \''+row.SUTA_Quote__r.State__c+'\'';
                    component.set("v.wcRateWhereClause", whereClause);
                }
                component.set("v.selectedStateCompCode", row.State_Comp_Code__c);
				component.set("v.selectedWcRateId", row.Id);
                component.set("v.selectedWcRateName", row.SUTA_Quote__r.State__r.Name +(row.Client_Loc__c!=undefined?" - "+row.Client_Loc__c:""));
                component.set("v.isShowStateRatingModal", true);
                component.set("v.isShowUploadModal", false);
                component.set("v.selectedClientLocation", row.Client_Location__c);
                component.set("v.mapClientLocationPicklistValues", []);
                helper.fetchClientLocationRecords(component, event, row.SUTA_Quote__r.State__c);
                break;
        }
    },
    
    handleHideWCRateAction : function(component, event, helper){
        component.set("v.selectedWcRateId", null);
        component.set("v.selectedWcRateName", null);
        component.set("v.isShowStateRatingModal", false);
        component.set("v.isShowUploadModal", true);
        component.set("v.oWCRate", null);
        component.set("v.wcRateWhereClause", null);
        component.set("v.selectedStateCompCode", null);
    },
    
    handleSaveWCRate : function(component, event, helper){
        var isValidate = helper.validateForm(component,'Gross_Wages,location');
        
        if(isValidate){
            let Part_Time_Employees = component.find("PartTimeEmployees").get("v.value");
            let of_Employees = component.find("ofEmployees").get("v.value");
            
            if(Part_Time_Employees == null || Part_Time_Employees == undefined || Part_Time_Employees == ''){
                Part_Time_Employees = 0
            }
            
            if(of_Employees == null || of_Employees == undefined || of_Employees == ''){
                of_Employees = 0
            }
            
            let selectedStateCompCode = component.get("v.selectedStateCompCode");
            var wcRate = component.get("v.oWCRate");
            if(selectedStateCompCode != null && selectedStateCompCode != undefined){
                if(Part_Time_Employees == 0 && of_Employees == 0){
                    helper.doShowToast(component, 'Error', '# of Part-Time Employees OR # of Full-Time Employees should be grater then 0', 'error');
                }else{ 
                    //helper.showSpinner(component);
                    
                    wcRate.Part_Time_Employees__c = Part_Time_Employees;
                    wcRate.of_Employees__c = of_Employees;
                    wcRate.Gross_Wages__c = component.find("Gross_Wages").get("v.value");
                    wcRate.State_Comp_Code__c = selectedStateCompCode;
                    wcRate.Client_Location__c = component.get("v.selectedClientLocation");
                    //component.find("editForm").submit(wcReate);
                    helper.updateWCRateHelper(component, event, wcRate);
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select valid WC Code', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please fill all required information and try again', 'error');
        }
        
    },
    
    handleSuccessSaveEditModal : function(component, event, helper){
        helper.doShowToast(component, 'Success', 'Record updated successfully', 'success');
        helper.handleInitlization(component, event);
        helper.getWCRateRecords(component, event);
        component.set("v.selectedWcRateId", null);
        component.set("v.selectedWcRateName", null);
        component.set("v.isShowStateRatingModal", false);
        component.set("v.isShowUploadModal", true);
        component.set("v.oWCRate", null);
        component.set("v.wcRateWhereClause", null);
        helper.hideSpinner(component);
    },
    
    handleErrorSaveEditModal : function(component, event, helper){
        var errorMessage = event.getParam("message");
        helper.doShowToast(component, 'Error', errorMessage, 'error');
        helper.hideSpinner(component);
    },

    handleShowAddWCCodeModal : function(component, event, helper){
        component.set("v.isShowAddCompCodeListModal", true);
    },
    
    handleHideAddWCCodeModal : function(component, event, helper){
        component.set("v.isShowAddCompCodeListModal", false);
    },
    
    handleAccordSignatureRequest: function(component, event, helper){
		helper.fetchAccordSignatureRequestURL(component, event, component.get("v.oSubmissionRequirement.Id"));
    },
    
    handleGenerateACORD: function(component, event, helper){
		helper.fetchGenerateACORD(component, event, component.get("v.oSubmissionRequirement.Id"));
    },
    
    
})