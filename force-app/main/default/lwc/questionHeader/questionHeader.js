import { LightningElement, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
 
import QUESTION_OBJECT from '@salesforce/schema/Questions__c';
import QUESTION_FIELD from '@salesforce/schema/Questions__c.Question__c';
import DATATYPE_FIELD from '@salesforce/schema/Questions__c.Data_Type__c';
import QUESTION_HEADER_FIELD from '@salesforce/schema/Questions__c.Question_Header__c';
import QUESTION_CHOICES_JSON_FIELD from '@salesforce/schema/Questions__c.Question_choices__c'; 
//new 
import questionSequence from '@salesforce/apex/QuestionSequenceTriggerHandlerSecond.questionSequence'; // Import the Apex method
import QUESTION_SEQUENCE_FIELD from '@salesforce/schema/Questions__c.Question_Sequence_new__c';

 
export default class QuestionHeader extends LightningElement {
    @api recordId;
    @track isShowModal2 = true;
    @track datatypeselection01 = true;
    @track datatypeselection = false;
    @track DateSelection = false;
    @track TextSelection = false;
    @track LikeDislike = false;
    @track MultiSelection = false;
    @track PickList = false;
    @track stars = false;
    @track multiSelectionOptions = [
        {value:'',placeholder:'Option 1'},
        {value:'',placeholder:'Option 2'}
    ];
    @track PickListOptions = [
        {value:'',placeholder:'Option 1'},
        {value:'',placeholder:'Option 2'}
    ];
    @track jsonmultiselectionoptions=[];
    @api readOnly;
    @api value;
    editedValue;
    isRendered;
    @track questionsArray = [];
    @track currentRating = 0;
   
    currentQuestion = '';
    datatype = '';
    iconName = 'utility:add';
 
    // Keep rest of the getters same as before...
 
    get ratingOptions() {
        return [1, 2, 3, 4, 5].map(value => ({
            value,
            starClass: `star ${value = 0 ? 'selected' : ''}`
        }));
    }
 
    get disableDelete() {
        return this.multiSelectionOptions.length <= 1, this.PickListOptions.length <= 1;
       
    }
   
    convertOptionsToJson(options, type) {
        try {
            const formattedOptions = options.map((option, index) => ({
                label: option.value || option.placeholder,
                value: option.value || option.placeholder,
            }));
            return JSON.stringify(formattedOptions);
        } catch (error) {
            console.error('Error converting options to JSON:', error);
            return '[]';
        }
    }

 
    handleRatingClick(event) {
        const rating = parseInt(event.currentTarget.dataset.rating, 10);
        this.currentRating = rating;
    }
 
    get booleangroup(){
        return[
            {label:'Like', value:'Like'},
            {label:'DisLike', value:'DisLike'},
        ];
    }
 
    toggleOptionEdit(event) {
        const index = event.target.dataset.index;
        this.multiSelectionOptions[index].isEditing = !this.multiSelectionOptions[index].isEditing;
    }
    toggleOptionEdit1(event) {
        const index = event.target.dataset.index;
        this.PickListOptions[index].isEditing = !this.PickListOptions[index].isEditing;
    }
   
    handleOptionValueChange(event) {
        const index = parseInt(event.target.dataset.index);
        const value = event.target.value;
        console.log('initialValues***',this.multiSelectionOptions);
        this.multiSelectionOptions = this.multiSelectionOptions.map((option, i) =>
            i === index ? { ...option, value } : {...option}
        );
        console.log('after input***',this.multiSelectionOptions)
    }
    handleOptionValueChange1(event) {
        console.log('Hello');
        const index = parseInt(event.target.dataset.index);
        const value = event.target.value;
        this.PickListOptions = this.PickListOptions.map((option, i) =>
            i === index ? { ...option, value } : option
        );
    }
 
    handleDeleteOption(event) {
        const index = parseInt(event.currentTarget.dataset.index);
        if (this.multiSelectionOptions.length > 1) {
            this.multiSelectionOptions = this.multiSelectionOptions.filter((_, i) => i !== index);
        }
    }
    handleDeleteOption1(event) {
        const index = parseInt(event.currentTarget.dataset.index);
        if (this.PickListOptions.length > 1) {
            this.PickListOptions = this.PickListOptions.filter((_, i) => i !== index);
        }
    } 
 
    get isSaveDisabled() {
        // Now we'll allow saving even with no questions in the array
        // Because we want to validate the current input when Finish is clicked
        return false;
    }
 
    handleQuestionChange(event) {
        this.currentQuestion = event.target.value;
    }
 
    handlePlusClick(event) {
        event.stopPropagation();
        if (this.iconName === 'utility:add') {
            this.iconName = 'utility:close';
            this.datatypeselection = true;
        } else {
            this.iconName = 'utility:add';
            this.datatypeselection = false;
        }
    }
 
    handleDeleteQuestion(event) {
        const index = event.target.dataset.index;
        this.questionsArray = this.questionsArray.filter((_, i) => i != index);
    }
 
    handleAddQuestion() {
        if (this.currentQuestion && this.datatype) {
            let questionData = {
                id: Date.now(),
                text: this.currentQuestion,
                datatype: this.datatype
            };
 
            // Add options data based on question type
            if (this.datatype === 'Multi Select') {
                questionData.options = this.convertOptionsToJson(this.multiSelectionOptions, 'multiselect');
            } else if (this.datatype === 'Pick List') {
                questionData.options = this.convertOptionsToJson(this.PickListOptions, 'picklist');
            }
 
            this.questionsArray.push(questionData);
           
            // Reset the form
            this.currentQuestion = '';
            this.resetFieldSelection();
            this.datatypeselection = false;
            this.iconName = 'utility:add';
            this.datatype = '';
        }
    }
 
    DatatypeField(event) {
        this.resetFieldSelection();
        this.iconName = 'utility:add';
        this.datatypeselection = false;
        this.datatype = event.target.value;
       
        if (event.target.label === 'Date') {
            this.DateSelection = true;
        } else if (event.target.label === 'Text') {
            this.TextSelection = true;
        } else if (event.target.label === 'Like/Dislike'){
            this.LikeDislike = true;
        } else if(event.target.label === 'Multiple-Selection'){
            this.MultiSelection = true;
            // this.handleMultiSelectionOptions();
        } else if(event.target.label === 'Picklist'){
            this.PickList = true;
        } else if(event.target.label ==='Rating'){
            this.stars = true;
        }
    }
 
    handleAddOption() {
        const newOptionNumber = this.multiSelectionOptions.length + 1;
        this.multiSelectionOptions = [
            ...this.multiSelectionOptions,
            { value: '', placeholder: `Option ${newOptionNumber}` }
        ];
    }
    handleAddOption1() {
        const newOptionNumber1 = this.PickListOptions.length + 1;
        this.PickListOptions = [
            ...this.PickListOptions,
            { value: '', placeholder: `Option ${newOptionNumber1}` }
        ];
    }
 
    resetFieldSelection() {
        this.DateSelection = false;
        this.TextSelection = false;
        this.LikeDislike = false;
        this.MultiSelection = false;
        this.PickList = false;
        this.stars = false;
    }
 
    hideModalBox() {
        this.datatypeselection01 = false;
        this.isShowModal2 = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    convertstringtojs(){
        this.jsonmultiselectionoptions = JSON.stringify(this.multiSelectionOptions);
    }
 
   /* CreateQuestionRecord() {
        // Check if there's a current question that hasn't been added yet
        if (this.currentQuestion && this.datatype) {
            this.handleAddQuestion(); // Add the current question to the array
        }
   
        if (this.questionsArray.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please add at least one question before saving',
                    variant: 'error'
                })
            );
            return;
        }
   
        const promises = this.questionsArray.map(question => {
            const fields = {};
            fields[DATATYPE_FIELD.fieldApiName] = question.datatype;
            fields[QUESTION_FIELD.fieldApiName] = question.text;
            fields[QUESTION_HEADER_FIELD.fieldApiName] = this.recordId;
           
           
            if (question.options) {
                fields[QUESTION_CHOICES_JSON_FIELD.fieldApiName] = question.options;
            }
 
   
            const recordInput = { apiName: QUESTION_OBJECT.objectApiName, fields };
            console.log('recordInput***',recordInput);
            return createRecord(recordInput)
                .then(record => {
                    console.log(`Question created with ID: ${record.id}`);
                    if ((question.datatype === 'Multi Select' || question.datatype === 'Pick List') && question.options) {
                        return this.convertOptionsToJson(record.id, JSON.parse(question.options));
                    }
                    return Promise.resolve();
                    // if (question.datatype === 'Multi Select') {
                    //     // Call CreateChoiceRecord only if datatype is 'Multi-select'
                    //     this.CreateChoiceRecord(record.id);
                    // }
                    // else if (question.datatype === 'Pick List') {
                    //     // Call CreateChoiceRecord only if datatype is 'Multi-select'
                    //     this.CreateChoiceRecord1(record.id);
                    // }
                });
        });
   
        Promise.all(promises)
            .then(() => {
                console.log('All questions created successfully');
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `${this.questionsArray.length} question(s) created successfully`,
                        variant: 'success'
                    })
                );
                //window.location.reload();
            })
            .catch(error => {
                console.error('Error creating records', error);
                const errorMessage = error.body && error.body.message ? error.body.message : 'An unexpected error occurred';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
            });
    }*/


            //new
            CreateQuestionRecord() {
                if (this.currentQuestion && this.datatype) {
                    this.handleAddQuestion();
                }
        
                if (this.questionsArray.length === 0) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please add at least one question before saving',
                            variant: 'error'
                        })
                    );
                    return;
                }
        
                // Fetch the current sequence size
                questionSequence({ questionHeaderId: this.recordId })
    .then(currentSequence => {
        console.log('Current sequence size:', currentSequence);

        if (currentSequence === null || currentSequence === undefined) {
            throw new Error('Failed to fetch the current sequence.');
        }

        let nextSequence = currentSequence + 1; // Start from the next sequence

        const promises = this.questionsArray.map(question => {
            const fields = {};
            fields[DATATYPE_FIELD.fieldApiName] = question.datatype;
            fields[QUESTION_FIELD.fieldApiName] = question.text;
            fields[QUESTION_HEADER_FIELD.fieldApiName] = this.recordId;
            fields[QUESTION_SEQUENCE_FIELD.fieldApiName] = nextSequence.toString(); // Convert to string

            if (question.options) {
                fields[QUESTION_CHOICES_JSON_FIELD.fieldApiName] = question.options;
            }

            const recordInput = { apiName: QUESTION_OBJECT.objectApiName, fields };
            nextSequence++; // Increment for the next record

            return createRecord(recordInput)
                .then(record => {
                    console.log(`Question created with ID: ${record.id}`);
                    if ((question.datatype === 'Multi Select' || question.datatype === 'Pick List') && question.options) {
                        return this.convertOptionsToJson(record.id, JSON.parse(question.options));
                    }
                    return Promise.resolve();
                });
        });

        Promise.all(promises)
            .then(() => {
                console.log('All questions created successfully');
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `${this.questionsArray.length} question(s) created successfully`,
                        variant: 'success'
                    })
                );
                //new
                //hideModalBox = false;
                //window.location.reload();
            })
            .catch(error => {
                console.error('Error creating records', error);
                const errorMessage = error.body && error.body.message ? error.body.message : 'An unexpected error occurred';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
            });
    })
    .catch(error => {
        console.error('Error fetching sequence size', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.message || 'Failed to fetch the current question sequence.',
                variant: 'error'
            })
        );
    });

}
}