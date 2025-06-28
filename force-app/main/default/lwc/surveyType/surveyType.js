import { LightningElement, wire, api, track } from 'lwc';
import getSurveyTypeRecords from '@salesforce/apex/SurveyType.getSurveyTypeRecords';
import createSurvey from '@salesforce/apex/SurveyType.createSurvey';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SurveyType extends LightningElement {

@api recordId;

@track surveyTypes = [];
@track selectedSurveyType = ''; // Store selected metadata type

// Wire the Apex method to fetch the survey types
    @wire(getSurveyTypeRecords)
    wiredSurveyTypes({ error, data }) {
        if (data) {
            console.log('Data:', data);
            this.surveyTypes = data.map(item => ({
               label: item.Name, // Displayed in the combobox
               value: item.Id, // Value of the option
               processing_Flow: item.Processing_Flow__c,
               response_Flow: item.Response_Flow__c
            }));
        } else if (error) {
            console.error('Error Fetching Survey Types:', error);
        }
    }

    // Handle the change of selected survey type
    handleSurveyTypeChange(event) {
        this.selectedSurveyType = event.detail.value;
    }

    handleSubmit() {
    console.log('Selected Survey Type:', this.selectedSurveyType);

    // Find the selected survey type object
    const selectedSurvey = this.surveyTypes.find(
        (survey) => survey.value === this.selectedSurveyType
    );

    if (!selectedSurvey) {
        this.showToast('Error', 'Invalid survey type selected.', 'error');
        return;
    }

    const processingFlow = selectedSurvey.processing_Flow;
    const responseFlow = selectedSurvey.response_Flow;

    if (!this.selectedSurveyType || !processingFlow || !responseFlow) {
        this.showToast('Error', 'Please fill in all required fields before submitting.', 'error');
        return;
    }

    const payload = {
        surveyType: this.selectedSurveyType,
        processingFlow: processingFlow,
        responseFlow: responseFlow,
        recordId: this.recordId,
    };

    console.log('Payload:', payload);

    // Call the Apex method to create the survey
    createSurvey({ payload })
        .then(() => {
            this.dispatchEvent(new CloseActionScreenEvent());
            this.showToast('Success', 'Survey created successfully.', 'success');
            this.resetForm();
        })
        .catch((error) => {
            console.error('Error creating survey:', error);
            this.showToast('Error', 'Failed to create survey. Please try again.', 'error');
        });
}


resetForm() {
        this.selectedSurveyType = ''; 
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}