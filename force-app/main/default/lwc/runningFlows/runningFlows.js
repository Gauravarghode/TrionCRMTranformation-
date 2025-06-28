import { LightningElement, track, api } from 'lwc';
import getRecordDetails from '@salesforce/apex/runningFlows.getRecordDetails';
import surveyMarked from '@salesforce/apex/SurveyMarked.surveyMarked';
import TrionLogo from '@salesforce/resourceUrl/TrionLogo';

export default class RunningFlows extends LightningElement {
    @api recordId;
    @api outputs;
    @track accountId;
    @track surveyType;
    @track processingFlow;
    @track processingFlowId;
    @track responseFlow;
    @track responseFlowId;
    @track surveyed;
    @track questions = [];
    @track question ;
    @track parsedOptions = [];
    @track isSurveyStarted = false;
    @track isSubmitted = false;
    @track isSurveyQuestions = false;
    @track isQuestionsEmpty = false;
    @track responses = [];
    @track error;
    @track selectedValues = [];
    @track responseValueList = [];
    @track dataList = [];
    @track value = '';
    @track jsonResponse = '';
    @track currentPage = 1;
    @track questionsPerPage = 5;
    renderProcessingFlow = true;
    renderResponseFlow = false;
    @track isLoading = true;

    get trionLogoUrl() {
        return TrionLogo;
    }

    fetchRecordDetails() {
        // Make the imperative call to getRecordDetails
        getRecordDetails({ sid: this.recordId })
            .then((data) => {
                console.log('Fetching survey details...');
                if (data) {
                    console.log('Fetched Data:', data);  // Log raw data to verify the structure
                    const surveyRecord = data.SurveyRecord;
                    const surveyTypeRecord = data.SurveyTypeRecord;

                    if (surveyRecord) {
                        this.accountId = surveyRecord.Account__c;
                        this.surveyType = surveyRecord.Survey_Type__c;
                        this.surveyed = surveyRecord.Surveyed__c;
                    }

                    if (surveyTypeRecord) {
                        this.processingFlow = surveyTypeRecord.Processing_Flow__c;
                        this.processingFlowId = surveyTypeRecord.Processing_Flow__r?.ApiName || null;
                        this.responseFlow = surveyTypeRecord.Response_Flow__c;
                        this.responseFlowId = surveyTypeRecord.Response_Flow__r?.ApiName || null;
                    }

                    console.log('Processed Details:', {
                        accountId: this.accountId,
                        surveyType: this.surveyType,
                        processingFlow: this.processingFlow,
                        processingFlowId: this.processingFlowId,
                        responseFlow: this.responseFlow,
                        responseFlowId: this.responseFlowId,
                        surveyed: this.surveyed
                    });
                }

                // Handle the surveyed value here
                if (this.surveyed === false) {
                    this.isSurveyStarted = true;
                    this.isSurveyQuestions = false;
                    this.isSubmitted = false;
                    this.isSurveyed = false;
                } else if (this.surveyed === true) {
                    this.isSurveyStarted = false;
                    this.isSurveyQuestions = false;
                    this.isSubmitted = false;
                    this.isSurveyed = true;
                }
            })
            .catch((error) => {
                console.error('Error fetching survey details:', error);
            });
    }

    // Fetch recordId from URL
    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        this.recordId = urlParams.get('sid');
        console.log('Record ID from URL:', this.recordId);
        setTimeout(()=>{
            this.isLoading = false;
            this.fetchRecordDetails();
        }, 1000)
        this.updateIconClasses();
    }

    get flowInputVariables() {
        console.log('RecordId:', this.accountId);
        return [
            {
                name: 'RecordId', // Flow input variable name
                type: 'String',
                value: this.accountId
            }
        ];

    }

    get processingFlowApiName() {
        console.log('Processing Flow ApiName:', this.processingFlowId);
        return this.processingFlowId; //  Returns the Processing Flow API name
    }

    handleStatusChange(event) {
        const status = event.detail.status;
        console.log('Processing Flow status:', status);

        if (status === 'FINISHED_SCREEN') {

            // Extract output variables from the flow
            const outputVariables = event.detail.outputVariables;
            console.log('Flow output variables:', outputVariables);
            this.flowOutputVariable = outputVariables;

            //  Get the variable with `isCollection: true`
            const dynamicVariable = outputVariables.find(
                variable => variable.isCollection && Array.isArray(variable.value)
            );
            console.log('dynamicVariable:', dynamicVariable);

            if (dynamicVariable) {
                const dynamicVariableName = dynamicVariable.name; // Get variable name
                const arrayValues = dynamicVariable.value; // Get its value (array)
                console.log('Dynamic Variable Name:', dynamicVariableName);
                console.log('Array Values:', arrayValues);

                // Assign values to a property 
                this.productNames = arrayValues; // Put Array Values(array) 
                this.questions = this.parseQuestions(arrayValues);

                console.log('Parsed Questions:', this.questions);
                console.log('Parsed Questions (stringified):', JSON.stringify(this.questions, null, 2));
                // Process and enhance question data types
                this.questions = this.questions.map((question) => ({
                    ...question,
                    isText: question.Data_Type__c === 'Text',
                    isRating: question.Data_Type__c === 'Rating',
                    isPicklist: question.Data_Type__c === 'Pick List',
                    isDate: question.Data_Type__c === 'Date',
                    isLikeDislike: question.Data_Type__c === 'Like / Dislike',
                    isMultiSelect: question.Data_Type__c === 'Multi Select'
                }));

                console.log('Processed Questions:', JSON.stringify(this.questions, null, 2));
            } else {
                console.warn('No suitable collection found in output variables.');
            }

        }
    }

    parseQuestions(arrayValues) {
        const questionArray = [];
        console.log('Properties with array values:', JSON.stringify(arrayValues));
        console.log('Array Length:', arrayValues.length);

        for (let i = 0; i < arrayValues.length; i += 4) {
            console.log('Processing chunk starting at index', i, ':', arrayValues.slice(i, i + 4));

            if (!arrayValues[i] || !arrayValues[i + 1] || !arrayValues[i + 2]) {
                console.warn('Invalid question structure at index ${i}:', arrayValues.slice(i, i + 4));
                continue;
            }

            console.log('Chunk values:', arrayValues[i], arrayValues[i + 1], arrayValues[i + 2]);

            // Parse options with the required structure
            let parsedOptions = [];
            if (arrayValues[i + 3]) {
                console.log('Raw options:', arrayValues[i + 3]);
                try {
                    const options = JSON.parse(arrayValues[i + 3]);
                    if (Array.isArray(options)) {

                        // Maping options to include only label if they are valid objects
                        parsedOptions = options.map(option => {
                            if (typeof option === 'object' && option.label) {
                                return { label: option.label, value: option.value+':'+arrayValues[i] };
                            } else {
                                console.warn('Invalid option structure:', option);
                                return null; // Handle invalid option
                            }
                        }).filter(option => option); // Remove null entries
                    } else {
                        console.warn('Options is not an array:', options);
                    }
                } catch (error) {
                    console.error('Error parsing options:', arrayValues[i + 3], error);
                }
            }

            const question = {
                id: arrayValues[i],
                //Name: arrayValues[i + 1],
                Question__c: arrayValues[i + 1],
                Data_Type__c: arrayValues[i + 2],
                options: parsedOptions, // Add the parsed options
                selectedValue: null,
                selectedValues: [],
                responseValueList: [],
            };

            questionArray.push(question);
            console.log('Pushed question:', JSON.stringify(question));
            console.log('Question Options:', JSON.stringify(question.options));
        }

        console.log('Final Question Array:', JSON.stringify(questionArray));
        return questionArray;
    }

    // Calculate start and end index for displaying 5 questions per page
    get paginatedQuestions() {
        //console.log('checkpage**',JSON.stringify(this.questions));
        const startIndex = (this.currentPage - 1) * this.questionsPerPage;
        const endIndex = (startIndex + this.questionsPerPage);
        // console.log('startIndex**',startIndex,'end***',endIndex);
        // console.log('checkpage**',JSON.stringify(this.questions.slice(startIndex, endIndex)));
        return this.questions.slice(startIndex, endIndex);
    }

    // Getter to check if the questions array is empty
    get isQuestionEmpty() {
        const isEmpty = this.questions.length === 0;
        console.log('Are questions empty?', isEmpty);
        return isEmpty;
    }

    surveyQuestions() {
        console.log('Survey started.');

        // Check if there are questions available
        if (!this.questions || this.questions.length === 0) {
            this.isQuestionsEmpty = true;
            this.isSurveyQuestions = false;
            this.isSurveyStarted = false;
            console.log('No questions available.');
            return;
        }

        // Proceed to show survey questions
        console.log('Questions:', JSON.stringify(this.questions));
        this.isSurveyQuestions = true;
        this.renderProcessingFlow = false;
        this.renderResponseFlow = false;
        this.isSurveyStarted = false;
        this.isQuestionsEmpty = false; // Ensure "No questions" message is not displayed
    }

    handleResponseChange(event) {
        const questionId = event.target.dataset.id; // Get question ID from data-id
        const responseValue = event.target.value; // Get the entered value
        // console.log('questionId**',JSON.stringify(questionId));
        
        // Find the question by ID
         this.question = this.questions.find(q => q.id === questionId);
        // console.log('changedquestion**',JSON.stringify(question));

        if (this.question) {
            // Update the selected value in the question
            this.question.selectedValues = responseValue;

            console.log('Question ID:', questionId);
            console.log('Response Value:', responseValue);
            console.log('Updated Question------->>>:', JSON.stringify(this.question));
            
            // Update the responses list
            this.addOrUpdateResponse(questionId, this.question.Question__c, responseValue);
            // console.log('Question Name', JSON.stringify(this.questions));
        } else {
            console.warn('Question not found for ID:', questionId);
        }
    }

     handlePicklistChange(event) {
        const questionId = event.target.dataset.id; // Get question ID from data-id
        const responseValue = event.target.value; // Get the entered value

        console.log('questionId**',JSON.stringify(questionId));
        console.log('questiondatatype**',JSON.stringify(event.target.dataset.datatype));

        // Find the question by ID
         this.question = this.questions.find(q => q.id === questionId);
        console.log('changedquestion**',JSON.stringify(this.question));

        if (this.question) {
            // Update the selected value in the question
            this.question.selectedValue = responseValue;

            console.log('Question ID:', questionId);
            console.log('Response Value:', responseValue);
            console.log('Updated Question:', JSON.stringify(this.question));

            
        // Update checked attribute for each checkbox
        this.question.options.forEach(option => {
            option.checked = this.question.selectedValue.includes(option.value);
        });
        
            if(event.target.dataset.datatype==="radio")
            {
                const inputString = responseValue;
                const splitResult = inputString.split(':');
                console.log('splitResult[0]*', splitResult[0]);
                this.addOrUpdateResponse(questionId, this.question.Question__c, splitResult[0]);
            }
            else
            {
                this.addOrUpdateResponse(questionId, this.question.Question__c, responseValue);
            }
            console.log('responseValue***', responseValue);
            // Update the responses list
          
            // console.log('Question Name', JSON.stringify(this.questions));
        } else {
            console.warn('Question not found for ID:', questionId);
        }
    }

    handleMultiSelectChange(event) {
    const questionId = event.target.dataset.id; // Get question ID from data-id
    const responseValue = event.target.value; // Get the selected value
    const dataType = event.target.dataset.datatype; // Get the data type from data-datatype
    console.log('Response Value:', responseValue);

    // Find the question by ID
     this.question = this.questions.find(q => q.id === questionId);

    if (this.question) {
        // Ensure selectedValues is an array
        if (!Array.isArray(this.question.selectedValues)) {
            this.question.selectedValues = [];
        }
        console.log('Question SelectedValues :', JSON.stringify(this.question.selectedValues));

        // Create or update a new list for storing response values
        if (!Array.isArray(this.question.responseValueList)) {
            this.question.responseValueList = [];
        }
       // Toggle the responseValue in the responseValueList
        const valueIndex = this.question.responseValueList.indexOf(responseValue);
        if (valueIndex === -1) {
            // Add the value if it doesn't exist
            this.question.responseValueList.push(responseValue);
        } else {
            // Remove the value if it already exists
            this.question.responseValueList.splice(valueIndex, 1);
        }
        console.log('Response Value List:', JSON.stringify(this.question.responseValueList));

        // Update checked attribute for each checkbox
        this.question.options.forEach(option => {
            option.checked = this.question.responseValueList.includes(option.value);
        });


        // Check if the data type is "checkbox"
        if (dataType === "checkbox") {
            // Extract the value before the colon
            const valueBeforeColon = responseValue.split(':')[0];
            console.log('Extracted Value:', valueBeforeColon);

            // Toggle the selected value
            const index = this.question.selectedValues.indexOf(valueBeforeColon);
            if (index === -1) {
                this.question.selectedValues.push(valueBeforeColon); // Add value if not already selected
            } else {
                this.question.selectedValues.splice(index, 1); // Remove value if already selected
            }

            // Add or update response with the selected values
            this.addOrUpdateResponse(questionId, this.question.Question__c, this.question.selectedValues);
        }

        console.log('Updated Selected Values:', JSON.stringify(this.question.selectedValues));
    } else {
        console.warn('Question not found for ID:', questionId);
    }
}


    handleLikeClick(event) {
    const button = event.currentTarget;
    const questionId = button.dataset.id;
    const likeElem = this.template.querySelector(`[data-id="${questionId}"][data-name="like"]`);
    const dislikeElem = this.template.querySelector(`[data-id="${questionId}"][data-name="dislike"]`);

    if (!questionId) {
        console.warn('data-id is missing from button');
        return;
    }

    this.question = this.questions.find(q => q.id === questionId);

    if (this.question) {
        // Toggle the selected value in the question
        this.question.selectedValue = this.question.selectedValue === 'Like' ? null : 'Like';
        this.addOrUpdateResponse(questionId, this.question.Question__c, this.question.selectedValue);
        this.updateIconClasses();

        // Update the icon styles based on selection state
        if (likeElem) {
            likeElem.classList.toggle('like-icn', this.question.selectedValue === 'Like');
        }
        if (dislikeElem) {
            dislikeElem.classList.toggle('dislike-icn', this.question.selectedValue === '');
        }
    } else {
        console.warn('Question not found for ID:', questionId);
    }
}

    handleDislikeClick(event) {
        const button = event.currentTarget;
        const questionId = button.dataset.id;
        const likeElem = this.template.querySelector(`[data-id="${questionId}"][data-name="like"]`);
        const dislikeElem = this.template.querySelector(`[data-id="${questionId}"][data-name="dislike"]`);

        if (!questionId) {
            console.warn('data-id is missing from button');
            return;
        }

        this.question = this.questions.find(q => q.id === questionId);

        if (this.question) {
            // Update the selected value in the question
        this.question.selectedValue = this.question.selectedValue === 'Dislike' ? null : 'Dislike';
        this.addOrUpdateResponse(questionId, this.question.Question__c, this.question.selectedValue);
        this.updateIconClasses();

        if (likeElem) {
            likeElem.classList.toggle('like-icn', this.question.selectedValue === '');
        }
        if (dislikeElem) {
            dislikeElem.classList.toggle('dislike-icn', this.question.selectedValue === 'Dislike');
        }
        } else {
            console.warn('Question not found for ID:', questionId);
        }
    }

updateIconClasses() {
    this.questions = this.questions.map(question => {
        return {
            ...question,
            likeIconClass: `slds-m-left_large ${question.selectedValue === 'Like' ? 'like-icn' : ''}`,
            dislikeIconClass: `slds-m-left_large ${question.selectedValue === 'Dislike' ? 'dislike-icn' : ''}`,
        };
    });
}

    handleStarRatingResponse(event) {
        const rating = event.detail; // Capture the rating from the event
        const questionId = event.target.dataset.id; // Get question ID from data-id
        // const responseValue = event.target.value; // Get the entered value

        // Find the question by ID
         this.question = this.questions.find(q => q.id === questionId);

        if (this.question) {
            // Update the selected value in the question
            this.question.selectedValue = rating;

            console.log('Selected Rating:', rating);
            console.log('Question Id:', questionId);
            console.log('Question Name:', this.question.Question__c);
            console.log('Response Value:', rating);

            this.addOrUpdateResponse(questionId, this.question.Question__c, String(rating));
        } else {
            console.warn('Question not found for ID:', questionId);
        }

    }

    addOrUpdateResponse(questionId, questionName, responseValue) {
        const existingResponse = this.responses.find((resp) => resp.QuestionId === questionId);

        if (existingResponse) {
            // Update existing response
            existingResponse.QuestionId = questionId;
            existingResponse.Question__c = questionName;
            existingResponse.Response = responseValue;
        } else {
            // Add new response
            this.responses.push({
                QuestionId: questionId,
                Question__c: questionName,
                Response: responseValue
            });
        }

        console.log('Updated Responses:', JSON.stringify(this.responses));

        // Convert responses to JSON format
        this.jsonResponse = JSON.stringify(this.responses);
        console.log('Responses in JSON format:', this.jsonResponse);
    }


    get isFirstQuestion() {
        return this.currentPage === 1;
    }

    get isLastQuestion() {
        const totalPages = Math.ceil(this.questions.length / this.questionsPerPage);
        return this.currentPage === totalPages;
    }

    handlePrevious() {
        if (!this.isFirstQuestion) {
            this.currentPage -= 1;
        }
         console.log('Updated Question:', JSON.stringify(this.question));
        this.isSurveyQuestions = true;
    }

    handleNext() {
        if (!this.isLastQuestion) {
            this.currentPage += 1;
        }
         console.log('Updated Question:', JSON.stringify(this.question));
    }

    get flowOutputtVariables() {
        this.dataList = [];
        // const urlParams = new URLSearchParams(window.location.search);
        // this.recordId = urlParams.get('sid');
        // console.log('Record ID from URL:', this.recordId);
        // // Logging for debugging
        // console.log('Response:', this.jsonResponse);
        // console.log('Account:', this.accountId);
        // console.log('Survey Id:', this.recordId);

        // console.log('responses', this.responses);
        this.responses.forEach(item => {
            console.log('item', item);
            this.dataList.push({ Questions__c: item.Question__c, Response__c: String(item.Response), Account__c: this.accountId, Survey__c: this.recordId });
        });

        console.log('this.dataList:', JSON.stringify(this.dataList));
        // console.log('this.dataList***', this.dataList); // Output the list

        return [
            {
                name: 'ResponseCollection',
                type: 'SObject',
                value: this.dataList // Assuming responses is an array or object
            },
        ];
    }

    get responseFlowApiName() {
        console.log('responseFlowApiName:', this.responseFlowId);
        return this.responseFlowId; //  Returns the Response Flow API name
    }

    handleSubmit() {
        this.renderResponseFlow = true; // Trigger flow rendering
        this.renderProcessingFlow = false;
        this.isSurveyStarted = false;



        console.log('Submit button clicked, recordId:', this.recordId);

        if (!this.recordId) {
            console.log('Error', 'Survey ID is missing.', 'error');
            return;
        }

        const surveyId = this.recordId;

        // Call Apex to mark the record as surveyed
        surveyMarked({ surveyId: surveyId })
            .then(() => {
                console.log('Survey marked as surveyed.', this.surveyed);
                this.isSurveyQuestions = false;
                //this.isSurveyed = true;
                this.isSubmitted = true;
            })
            .catch(error => {
                console.error('Error marking survey as surveyed:', error);
            });
    }

    handleOutputStatusChange(event) {
        console.log('Flow status change event:', event);

        if (event.detail.status === 'FINISHED_SCREEN') {
            console.log('Flow executed successfully!');
        } else if (event.detail.status === 'ERROR') {
            console.error('Flow execution failed:', event.detail);
            alert('An error occurred while executing the flow. Please check your configuration.');
        } else {
            console.warn('Flow did not finish or encounter an error:', event.detail.status);
        }
    }
}