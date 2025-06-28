import { LightningElement, api, track } from 'lwc';
import getSharepointData1 from '@salesforce/apex/GetCsvUsingCaseSPId_checkV12.getSharepointId';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { NavigationMixin } from 'lightning/navigation';


export default class TrionCaseEmailActivity extends NavigationMixin(LightningElement) {
    @api recordId;
    @track emails = [];
    @track emailsToDisplay = [];
    @track showEmails = false;
    @track isDataLoaded = false;
    subscription = {};
    channelName = '/event/ListMapPlatform_V2__e';
    caseRecord = {};
     processedIds = new Set();

       connectedCallback() {
        this.subscribeToPlatformEvents()
            .then(() => {
                this.runFirstMethod();
            })
            .catch(error => {
                console.error('Error during initialization:', error);
            });
    }

    disconnectedCallback() {
        this.unsubscribeFromPlatformEvents();
    }

    // runFirstMethod() {
    //     getSharepointData1({ caseParentId: this.recordId })
    //         .then(result => {
    //             this.emails = result.map(item => {
    //                 return { ...item, CreatedDate: this.formatDate(item.CreatedDate) };
    //             });
    //             this.sortEmails();
    //             console.log('First method executed successfully with result:', JSON.stringify(result));
    //         })
    //         .catch(error => {
    //             console.error('Error executing first method:', error);
    //         });
    // }

        runFirstMethod() {
        getSharepointData1({ caseParentId: this.recordId })
            .then(() => {
                console.log('First method executed successfully',);
            })
            .catch(error => {
                console.error('Error executing first method:', error);
            });
    }

    subscribeToPlatformEvents() {
    return new Promise((resolve, reject) => {
        const messageCallback = (response) => {
            console.log('New platform event received: ', response);
            this.handlePlatformEvent(response.data.payload);
        };

        subscribe(this.channelName, -1, messageCallback)
            .then(response => {
                console.log('Subscription request sent to: ', JSON.stringify(response.channel));
                this.subscription = response;
                resolve();
            })
            .catch(error => {
                console.error('Error in platform event subscription: ', error);
                reject(error);
            });

        onError(error => {
            console.error('Error in platform event subscription: ', error);
            reject(error);
        });
    });
}

    unsubscribeFromPlatformEvents() {
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from: ', JSON.stringify(response));
            });
        }
    }


    handlePlatformEvent(eventPayload) {
    console.log('Raw platform event payload:', eventPayload);
    try {
        const parsedData = {
            IdOfCsv: eventPayload.Id__c,
            ParentId: eventPayload.ParentId__c,
            ToAddress: eventPayload.ToAddress__c,
            CreatedDate: eventPayload.CreatedDate__c,
            BccAddress: eventPayload.BccAddress__c,
            CreatedDate: eventPayload.CreatedDate__c,
            CreatedById: eventPayload.CreatedById__c,
            HtmlBody: eventPayload.HtmlBody__c,
            CreatedByUserName: eventPayload.CreatedByName__c,

        };

        console.log('Processing event payload:', parsedData);

        if (parsedData.ParentId === this.recordId) {
            const newEmail = {
                    ToAddress: parsedData.ToAddress || '',
                    IdOfCsv: parsedData.IdOfCsv || '',
                    BccAddress: parsedData.BccAddress || '',
                    ParentId: parsedData.ParentId || '',
                    CreatedDate: this.formatDate(parsedData.CreatedDate || ''),
                    CreatedById: parsedData.CreatedById || '',
                    HtmlBody: parsedData.HtmlBody || '',
                    CreatedByUserName: parsedData.CreatedByUserName || '',
            };

            if (!this.processedIds.has(newEmail.IdOfCsv)) {
                this.processedIds.add(newEmail.IdOfCsv);
                this.emails = [...this.emails, newEmail];
                this.emailsToDisplay = this.emails.slice(0, 2);
                this.showEmails = this.emailsToDisplay.length > 0;

                console.log('Processed platform event payload: ', newEmail);
            } else {
                console.log('Duplicate email ignored: ', newEmail.IdOfCsv);
            }
        } else {
            console.log('Platform event ignored: ParentId does not match current recordId');
        }
    } catch (error) {
        console.error('Error processing platform event payload: ', error);
    }
}

    // handlePlatformEvent(csvInfoList) {
    //     console.log('Raw platform event payload:', csvInfoList);
    //     try {
    //         const parsedData = this.stringToObject(csvInfoList);
    //         console.log('Processing event payload:', parsedData);

    //         if (parsedData.ParentId === this.recordId) {
    //             const emailId = parsedData.IdOfCsv;
                
    //             if (!this.processedIds.has(emailId)) {
    //                 const newEmail = {
    //                 ToAddress: parsedData.ToAddress || '',
    //                 IdOfCsv: parsedData.IdOfCsv || '',
    //                 BccAddress: parsedData.BccAddress || '',
    //                 ParentId: parsedData.ParentId || '',
    //                 CreatedDate: this.formatDate(parsedData.CreatedDate || ''),
    //                 CreatedById: parsedData.CreatedById || '',
    //                 HtmlBody: parsedData.HtmlBody || '',
    //                 CreatedByUserName: parsedData.CreatedByUserName || '',
    //                 };

    //                 this.emails.push(newEmail);
    //                 this.sortEmails();

    //                 this.processedIds.add(emailId);

    //                 console.log('Processed platform event payload: ', newEmail);
    //             } else {
    //                 console.log('Duplicate event ignored: ID already processed');
    //             }
    //         } else {
    //             console.log('Platform event ignored: ParentId does not match current recordId');
    //         }
    //     } catch (error) {
    //         console.error('Error parsing platform event payload: ', error);
    //     }
    // }

stringToObject(str) {
        const predefinedKeys = [
            'ToAddress', 'CreatedById', 'CreatedDate', 'ParentId',
            'IdOfCsv', 'HtmlBody', 'CreatedByUserName', 'BccAddress'
        ];

        str = str.trim().slice(1, -1); // Adjusted slicing to handle both opening and closing parentheses

        const obj = {};
        let regex = /([^=]+)=([^,{}]+?(?=,|})|[^{}]+)(?:,|$)/g;
        let match;
        let currentKey = '';
        let currentValue = '';
        let isHtmlBody = false;

        while ((match = regex.exec(str)) !== null) {
            let key = match[1].trim();
            let value = match[2].trim();

            // Handle possible quotes around values
            let cleanedValue = value.replace(/^"(.*)"$/, '$1');

            if (predefinedKeys.includes(key)) {
                if (key === 'HtmlBody') {
                    isHtmlBody = true;
                    currentKey = key;
                    currentValue = cleanedValue;
                } else {
                    obj[key] = cleanedValue;
                }
            } else if (isHtmlBody) {
                currentValue += `,${match[0]}`; // Continue appending to HtmlBody until next key is found
            }

            if (!isHtmlBody && currentKey === 'HtmlBody' && currentValue) {
                obj[currentKey] = currentValue;
                currentKey = '';
                currentValue = '';
                isHtmlBody = false;
            }
        }

        if (currentKey === 'HtmlBody' && currentValue) {
            obj[currentKey] = currentValue;
        }

        return obj;
    }


sortEmails() {
        this.emails = this.emails.sort((a, b) => (a.CreatedDate > b.CreatedDate ? -1 : 1));
    }

    navigateToUser(event) {
        event.preventDefault();
        const selectedUserId = event.target.dataset.userid;
        console.log('Selected User ID:', selectedUserId);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedUserId,
                actionName: 'view'
            }
        });
    }

    formatDate(dateString) {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const formattedDate = new Date(dateString).toLocaleDateString('en-US', options);
        return formattedDate;
    }
}