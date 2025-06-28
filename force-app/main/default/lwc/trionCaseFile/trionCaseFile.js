import { LightningElement, api, track } from 'lwc';
import getRelatedFiles from '@salesforce/apex/GetFileUsingCaseSPId_V1.getCaseFolderData';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class TrionCaseFiles extends NavigationMixin(LightningElement) {
    @api recordId;
    @track filesList = [];
    @track filesToDisplay = [];
    showFiles = false;
    subscription = {};
    channelName = '/event/FileListMapPlatform__e';
    processedIds = new Set();

    connectedCallback() {
        this.runFirstMethod();
        this.subscribeToPlatformEvents();
    }

    disconnectedCallback() {
        this.unsubscribeFromPlatformEvents();
    }

    runFirstMethod() {
        getRelatedFiles({ caseParentId: this.recordId })
            .then(() => {
                console.log('First method executed successfully');
            })
            .catch(error => {
                console.error('Error executing first method:', error);
            });
    }

    subscribeToPlatformEvents() {
        const messageCallback = (response) => {
            console.log('New platform event received:', response);
            this.handlePlatformEvent(response.data.payload.fileDataPlatform__c);
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to:', JSON.stringify(response.channel));
            this.subscription = response;
        });

        onError(error => {
            console.error('Error in platform event subscription:', error);
        });
    }

    unsubscribeFromPlatformEvents() {
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from:', JSON.stringify(response));
            });
        }
    }

    handlePlatformEvent(fileDataPlatform) {
        console.log('Raw platform event payload:', fileDataPlatform);
        try {
            const parsedData = this.stringToObject(fileDataPlatform);
            console.log('Processing event payload:', parsedData);

            if (parsedData.ParentId === this.recordId) {
                const fileId = parsedData.fileId;

                if (!this.processedIds.has(fileId)) {
                    let fileEx = parsedData.fileType.split("/")[1];
                    if (fileEx === 'vnd.openxmlformats-officedocument.wordprocessingml.document') {
                        fileEx = 'docx';
                    } 
                    let iframeUrl = 'https://trionworks.sharepoint.com/sites/SalesforceArchive/_layouts/15/embed.aspx?UniqueId=' + parsedData.eTag;
                    const newFile = {
                        name: parsedData.name || '',
                        fileExtension: fileEx,
                        createdDateTime: this.formatDate(parsedData.createdDateTime || ''),
                        fileId: parsedData.fileId || '',
                        ParentId: parsedData.ParentId || '',
                        eTag: parsedData.eTag || '',
                        iframeUrl: iframeUrl,
                         downloadUrl: parsedData.downloadUrl,
                        size: this.formatSize(parsedData.size || ''),
                        fileIcon: this.fileIconPicker(fileEx)
                    };

                    this.filesList.push(newFile);
                    this.filesToDisplay = this.filesList.slice(0, 2);
                    this.showFiles = this.filesToDisplay.length > 0;

                    this.processedIds.add(fileId);

                    console.log('Processed platform event payload:', newFile);
                } else {
                    console.log('Duplicate event ignored: ID already processed');
                }
            } else {
                console.log('Platform event ignored: ParentId does not match current recordId');
            }
        } catch (error) {
            console.error('Error parsing platform event payload:', error);
        }
    }



    stringToObject(str) {
    const predefinedKeys = ['name', 'fileType', 'createdDateTime', 'ParentId', 'fileId', 'size', 'downloadUrl', 'eTag'];

    str = str.trim().slice(1, -1);

    const obj = {};
    const regex = /([^=]+)=((?:https?:\/\/[^\s,]+)|(?:[^,]+))(?:,|$)/g;
    let match;

    while ((match = regex.exec(str)) !== null) {
        const key = match[1].trim();
        const value = match[2].trim();

        if (predefinedKeys.includes(key)) {
            obj[key] = value;
        }
    }

    const eTagRegex = /eTag=([^,]+)/;
    const eTagMatch = str.match(eTagRegex);
    if (eTagMatch) {
        obj['eTag'] = eTagMatch[1].trim();
    }

    return obj;
}




    formatDate(dateString) {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const formattedDate = new Date(dateString).toLocaleDateString('en-US', options);
        return formattedDate;
    }
    get cardLabel() {
        return 'Files (' + this.filesList.length + ')';
    }
    formatSize(size) {
        if (size >= 1024 * 1024) {
            return Math.round(size / (1024 * 1024)) + " MB";
        } else {
            return Math.round(size / 1024) + " KB";
        }
    }

    showAllFiles(event) {
        var compDefinition = {
            componentDef: "c:trionAllCaseFiles",
            attributes: {
                recordId: this.recordId
            }
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }

    fileIconPicker(extension) {
        if (extension == 'png' || extension == 'jpeg' || extension == 'jpg') {
            return 'doctype:image';
        } else if (extension == 'pdf') {
            return 'doctype:pdf';
        } else if (extension == 'doc' || extension == 'docx' || extension == 'msword') {
            return 'doctype:word';
        } else {
            return 'standard:document_preview';
        }
    }
     openPreview(event) {
 
       event.preventDefault();
    const selectedId = event.target.dataset.id;
    let selectedFile ;
        this.filesList.forEach( (file)=>{ if(file.fileId == selectedId){ selectedFile = file }} );
    console.log('selectedFile', selectedFile );

    if (selectedFile) {
        const showPreview = this.template.querySelector("c-file-preview");
        if (showPreview) {
            showPreview.fileDetails = selectedFile;
            showPreview.show();
            console.log('Modal opened');
        }
    }
  }
}