import { LightningElement, api, track } from 'lwc';
import getRelatedFilesByEmailId from '@salesforce/apex/GetCsvUsingCaseSPId_V2.getfileDataTwoParameter';
import { NavigationMixin } from 'lightning/navigation';
import getCaseDetails from '@salesforce/apex/GetCsvUsingCaseSPId_V2.getCaseRecordbyId';

export default class TrionViewAllEmailFiles extends NavigationMixin(LightningElement) {
    @api recordId;
    @api emailId;
    //@api caseId;
    @track files = [];
    get _files() {
        return this.files;
    }
    isDataLoaded = false;
    caseEmailRecord = {};

    get fileCounter() {
        return this.files.length;
    }

    connectedCallback() {
        console.log('emailId:', this.emailId);
        console.log('caseId:', this.recordId);
        
        getRelatedFilesByEmailId({ caseParentId: this.recordId, eachEmailMessageIdFromSp: this.emailId })
            .then(result => {
                this.handleResponse(result);
                this.isDataLoaded = true;
                console.log('Files:', JSON.stringify(this.files));
            })
            .catch(error => {
                console.error('Error occurred retrieving SharePoint data...', error);
            });

        getCaseDetails({ caseId: this.recordId })
            .then(result => {
                console.log('Result:', result);
                this.caseEmailRecord = result;
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    openCaseRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseEmailRecord.Id,
                actionName: 'view'
            }
        });
    }

    openCaseList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    handleResponse(data) {
        console.log('Handling response... ', data);
        
        try {
            let valueList = JSON.parse(data).value;
            this.attachmentsCounter = valueList.length;

            this.files = [];
            valueList.forEach(item => {
                console.log(JSON.stringify(item));
                if (!(item.name.includes("EmailMessageDetails") && item.file.mimeType == "application/vnd.ms-excel")) {
                    let etag = item["eTag"];
                    let etagEndIndex = etag.indexOf("}");
                    let etagSubstr = etag.substring(2, etagEndIndex);
                    let fileEx = item.file.mimeType.split("/")[1];
                    if (fileEx === 'vnd.openxmlformats-officedocument.wordprocessingml.document') {
                        fileEx = 'docx';
                    }
                    let icon = this.fileIconPicker(fileEx);

                    console.log('etag ' + etagSubstr + ' raw ' + etag);
                    let iframeUrl = 'https://trionworks.sharepoint.com/sites/SalesforceArchive/_layouts/15/embed.aspx?UniqueId=' + etagSubstr;
                    let newItem = {
                        name: item.name,
                        downloadUrl: item["@microsoft.graph.downloadUrl"],
                        size: this.formatSize(item.size),
                        fileExtension: fileEx,
                        createdDateTime: this.formatDate(item.fileSystemInfo.createdDateTime),
                        eTag: etagSubstr,
                        webUrl: item.webUrl,
                        iframeUrl: iframeUrl,
                        fileId: item.id,
                        fileIcon: icon,
                        lastModified: this.formatDate(item.lastModifiedDateTime),
                        createdBy: item.createdBy.user.displayName,
                        showAction: false,
                        fullFileType: item.file.mimeType,
                    };
                    console.log('processed item ' + JSON.stringify(newItem));
                    this.files.push(newItem);
                }
            });
            console.log('~~~ finished processing');
            console.log(JSON.stringify(this.files));
        } catch (error) {
            console.error('Error parsing response data:', error);
        }
    }

    formatDate(dateString) {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        const formattedDate = new Date(dateString).toLocaleDateString('en-US', options);
        return formattedDate;
    }

    formatSize(size) {
        if (size >= 1024 * 1024) {
            return Math.round(size / (1024 * 1024)) + " MB";
        } else {
            return Math.round(size / 1024) + " KB";
        }
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
        const selectedFile = this._files.find(item => item.fileId == selectedId);

        if (selectedFile) {
            const showPreview = this.template.querySelector("c-file-preview");
            if (showPreview) {
                showPreview.fileDetails = selectedFile;
                showPreview.show();
                console.log('Modal opened');
            }
        }
    }

    handleFileDelete(evt) {
        evt.preventDefault();
        const selectedId = event.target.dataset.id;
        const selectedFile = this._files.find(item => item.fileId == selectedId);

        deleteFileAction({ fileSharepointId: selectedFile.fileId })
            .then(result => {
                this.showDeleteSuccessToast();
                console.log('Result', result);
            })
            .catch(error => {
                this.showDeleteErrorToast();
                console.error('Error:', error);
            });
    }

    showDeleteSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Successfully Deleted!',
            variant: 'warning',
            mode: 'pester',
            message: 'File has been deleted successfully!',
        });
        this.dispatchEvent(event);
    }

    showDeleteErrorToast() {
        const event = new ShowToastEvent({
            title: 'Delete Failed.',
            variant: 'error',
            mode: 'pester',
            message: 'File Delete Failure: An unexpected Error has occurred.',
        });
        this.dispatchEvent(event);
    }

    handleActionMenu(evnt) {
        evnt.preventDefault();
        const selectedId = evnt.target.dataset.id;
        const selectedFile = this._files.find(item => item.fileId == selectedId);

        selectedFile.showAction = !selectedFile.showAction;
    }
}