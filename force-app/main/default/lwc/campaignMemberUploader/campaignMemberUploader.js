import { LightningElement, api, track } from 'lwc';
import previewCsvFile from '@salesforce/apex/CampaignMemberUploader.previewCsvFile';
import insertSelectedContacts from '@salesforce/apex/CampaignMemberUploader.insertSelectedContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CampaignMemberUploader extends LightningElement {
    @api recordId;
    file;
    fileContents;
    disableUpload = true;
    disableInsert = true;
    isLoading = false;
    accountIdIncluded = true;
    buttonTitle = 'Download your file'; // Default title
    @track isSecondModalOpen = false;


    @track contact_Insert_count = 0;
    @track contact_Total_count = 0;
    @track contact_Ex_count = 0;
    @track contact_Error_count = 0;
    @track campaignmember_insert_count= 0;
    @track campaignmember_ex_count= 0;
    
    @track disableDownload = true; //new

    @track isModalOpen = false;
    @track columns = [];
    @track contactsData = [];

    // connectedCallback() {
    //     this.columns = [
    //         {
    //             type: 'number',
    //             fieldName: 'rowNumber',
    //             label: '#SNo',
    //             initialWidth: 80,
    //             sortable: false
    //         },
    //     ];
    // }

    handleFileChange(event) {
        const fileInput = event.target.files;
        if (fileInput.length > 0) {
            this.file = fileInput[0];
            if (this.file.type === 'text/csv' || this.file.name.endsWith('.csv')) {
                this.disableUpload = false;
            } else {
                this.showErrorToast('Invalid File Type', 'Please upload a valid CSV file.');
                this.disableUpload = true;
            }
        }
    }

    handleUpload() {
        if (this.file) {
            this.readFile();
        } else {
            this.showErrorToast('No File Selected', 'Please select a CSV file to upload.');
        }
    }

    readFile() {
        const reader = new FileReader();
        reader.onload = () => {
            this.fileContents = reader.result;
            if (!this.fileContents || this.fileContents.trim() === '') {
                this.showErrorToast('Empty File', 'The uploaded CSV file is empty.');
                return;
            }
            this.previewCsvFile();
        };
        reader.readAsText(this.file);
    }

    previewCsvFile() {
        const base64Data = btoa(this.fileContents);
        this.isLoading = true;
    
        previewCsvFile({ base64Data: base64Data, campaignId: this.recordId })
            .then((result) => {
                const processedData = result.data.map((row, index) => {
                    // Remove trailing \r from any field, especially the last column
                    const sanitizedRow = Object.fromEntries(
                        Object.entries(row).map(([key, value]) => [key, (value).replace(/\r?\n|\r/g, '').trim()])
                    );
                    
                    return {
                        rowNumber: index + 1,
                        ...sanitizedRow,
                        AccountId: sanitizedRow.AccountId || '',
                        statusClass: this.getStatusClass(sanitizedRow.status),
                        Error: sanitizedRow.Error || ''
                    };
                });
    
                // Reset counters
                this.contact_Total_count = processedData.length;
                this.contact_Error_count = processedData.filter(row => row.status === 'Error').length;
                this.contact_Ex_count = processedData.filter(row => row.status === 'Existing').length;
                this.campaignmember_insert_count++;
                this.campaignmember_ex_count = processedData.filter(row => row.status === 'Already in Campaign').length;
    
                this.setupDataTableColumns(result.columns);
                this.contactsData = processedData;
                this.disableInsert = false;
                this.openModal();
            })
            .catch((error) => {
                this.showErrorToast('Error processing CSV', error.body?.message || 'An unexpected error occurred.');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    

    handleInsert() {
        this.disableInsert = true;
        if (this.contactsData.length === 0) {
            this.showErrorToast('No Rows Available', 'There are no rows to insert.');
            return;
        }
    
        this.isLoading = true;
    
        insertSelectedContacts({ selectedContacts: this.contactsData, campaignId: this.recordId })
            .then((results) => {
                let hasErrors = false;
                let updatedData = [...this.contactsData];
                
                // Reset counters for insert operation
                this.contact_Insert_count = 0;
                this.campaignmember_insert_count = 0;
    
                // Process the results
                results.forEach(result => {
                    const rowIndex = updatedData.findIndex(
                        row => row.Email?.toLowerCase() === result.Email?.toLowerCase()
                    );
    
                    if (rowIndex !== -1) {
                        if (result.Error) {
                            hasErrors = true;
                            this.contact_Error_count++;
                            updatedData[rowIndex] = {
                                ...updatedData[rowIndex],
                                status: 'Error',
                                statusClass: 'slds-text-color_error',
                                Error: result.Error
                            };
                        }
                    }
                });
    
                // Update successful insertions
                updatedData.forEach(row => {
                    if (row.status !== 'Already in Campaign' && row.status !== 'Existing' && !row.Error) {
                        this.contact_Insert_count++;
                        this.campaignmember_insert_count++;
                        row.status = 'Inserted';
                        row.statusClass = 'slds-text-color_success';
                    }
                    //Modifying sujatha
                    if (row.status !== 'Already in Campaign' && row.status === 'Existing' && !row.Error) {
                        this.campaignmember_insert_count++;
                        row.status = 'Inserted';
                        row.statusClass = 'slds-text-color_success';
                    }
                });
                
                console.log(this.contact_Insert_count , '---> contact insert val?');
                console.log(this.contact_Error_count , '---> contact error val?');
                console.log(this.contact_Total_count , '---> contact total val?');
                console.log(this.contact_Ex_count , '---> contact ex val?');
                console.log(this.campaignmember_ex_count , '---> camp ex val?');
                console.log(this.campaignmember_insert_count , '---> camp insert val?');
                this.contactsData = updatedData;
    
                // Show appropriate toast messages
                // if (hasErrors) {
                //     if (this.contact_Insert_count > 0) {
                //         this.showMixedToast(
                //             'Partial Success',
                //             `Successfully inserted ${this.contact_Insert_count} contacts and ${this.campaignmember_insert_count} campaign members. ${this.contact_Error_count} errors occurred.`
                //         );
                //     } else {
                //         this.showErrorToast('Error', 'Failed to insert records. Check the Error column for details.');
                //     }
                // } else {
                //     this.showSuccessToast('Success', `Successfully inserted ${this.contact_Insert_count} contacts and ${this.campaignmember_insert_count} campaign members!`);
                // }
                this.disableDownload = false;//new
                this.secondmodal();
            })
            .catch((error) => {
                this.showErrorToast('Error Inserting Contacts', error.body?.message || 'An unexpected error occurred.');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }


    getStatusClass(status) {
        switch (status?.toLowerCase()) {
            case 'error':
                return 'slds-text-color_error';
            case 'inserted':
            case 'success':
                return 'slds-text-color_success';
            case 'existing':
                return 'slds-text-color_warning';
            default:
                return 'slds-text-color_default';
        }
    }

    setupDataTableColumns(resultColumns) {
        const columnsToExclude = ['_Account Name', '_Campaign Name', '_Status', '_Validation','Account Name', 'Campaign Name', 'Status', 'Validation'];
        const baseColumns = resultColumns.map(header => ({
            // Remove any \r from the header
            label: header.replace(/\r?\n|\r/g, '').trim(),
            fieldName: header.replace(/\r?\n|\r/g, '').trim(), // Sanitize fieldName too
            type: 'text',
            wrapText: true,
            initialWidth: header === 'AccountId' ? 135 : undefined
        }));
        const filteredColumns = baseColumns.filter(column => !columnsToExclude.includes(column.label)); 

        // Add additional columns
        this.columns = [
            // ...baseColumns.filter(column => column.fieldName !== 'AccountId' || this.accountIdIncluded),
            {
                type: 'number',
                fieldName: 'rowNumber',
                label: '#SNo',
                initialWidth: 50,
                sortable: false,
                wrapText: false,
                cellAttributes: { alignment: 'left' },
                filterable: false,
                typeAttributes: {
                    'header-class': 'slds-text-align_center'
                },
                overfllow:false,
                columnActions: {
                    editable: false,
                    sortable: false,
                    resizable: false,
                    wrapText: false,
                    cliptext: false
                },
                hideDefaultActions:true
            },
            ...filteredColumns,
            {
                label: 'Account Name',
                fieldName: 'AccountName',
                type: 'text',
                wrapText: true
            },
            // {
            //     label: 'Account Id',
            //     fieldName: 'AccountId',
            //     type: 'text',
            //     wrapText: true
            // },
            {
                label: 'Campaign Name',
                fieldName: 'CampaignName',
                type: 'text'
            },
            {
                label: 'Status',
                fieldName: 'status',
                type: 'text',
                cellAttributes: {
                    class: { fieldName: 'statusClass' }
                }
            },
            {
                label: 'Validation',
                fieldName: 'Error',
                type: 'text',
                wrapText: true,
                cellAttributes: {
                    class: 'slds-text-color_error'
                },
                initialWidth: 300
            }
        ];
    }

    // handleInsert() {
    //     this.disableInsert = true;
    //     if (this.contactsData.length === 0) {
    //         this.showErrorToast('No Rows Available', 'There are no rows to insert.');
    //         return;
    //     }
    
    //     this.isLoading = true;
    
    //     // Pass all rows by default since there's no selection anymore
    //     insertSelectedContacts({ selectedContacts: this.contactsData, campaignId: this.recordId })
    //         .then((results) => {
    //             let hasErrors = false;
    //             let successCount = this.contactsData.length; 
    //             this.contact_Total_count = this.contactsData.length; 
    //             let updatedData = [...this.contactsData];
    
    //             // Process the results returned from the server
    //             if (results && Array.isArray(results)) {
    //                 results.forEach(result => {
    //                     const rowIndex = updatedData.findIndex(
    //                         row => row.Email?.toLowerCase() === result.Email?.toLowerCase()
    //                     );
    
    //                     if (rowIndex !== -1) {
    //                         if (result.Error) {
    //                             hasErrors = true;
    //                             successCount--; // Reduce success count if there's an error
    //                             this.contact_Error_count++;
    //                             updatedData[rowIndex] = {
    //                                 ...updatedData[rowIndex],
    //                                 status: 'Error',
    //                                 statusClass: 'slds-text-color_error',
    //                                 Error: result.Error
    //                             };
    //                         } else {
    //                             updatedData[rowIndex] = {
    //                                 ...updatedData[rowIndex],
    //                                 status: 'Inserted',
    //                                 statusClass: 'slds-text-color_success',
    //                                 Error: ''
    //                             };
    //                         }
    //                     }
    //                 });
    //             }
    
    //             // Update any rows that weren't in the results as successful
    //             updatedData.forEach(row => {
    //                 const resultIndex = results.findIndex(
    //                     result => result.Email?.toLowerCase() === row.Email?.toLowerCase()
    //                 );
    
    //                 if (resultIndex === -1 && row.status !== 'Error' && row.status !== 'Already in Campaign' && row.status !== 'Existing') {
    //                     this.contact_Insert_count++;
    //                     row.status = 'Inserted';
    //                     row.statusClass = 'slds-text-color_success';
    //                     row.Error = '';
    //                 }
    //                 if (resultIndex === -1 && row.status === 'Existing') {
    //                     this.contact_Ex_count++;
    //                 }
    //                 if (resultIndex === -1 && row.status === 'Already in Campaign') {
    //                     this.campaignmember_ex_count++;
    //                 }

    //             });
    //             console.log(this.contact_Insert_count , '---> contact insert val?');
    //             console.log(this.contact_Error_count , '---> contact error val?');
    //             console.log(this.contact_Total_count , '---> contact total val?');
    //             console.log(this.contact_Ex_count , '---> contact ex val?');
    //             console.log(this.campaignmember_ex_count , '---> camp ex val?');
                
    //             // Update the data table with the final statuses
    //             this.contactsData = [...updatedData];
    
    //             // Show appropriate toast messages
    //             if (hasErrors) {
    //                 if (successCount > 0) {
    //                     this.showMixedToast(
    //                         'Partial Success',
    //                         `Successfully inserted ${successCount} out of ${this.contactsData.length} records. Check the Error column for details.`
    //                     );
    //                 } else {
    //                     this.showErrorToast('Error', 'Failed to insert records. Check the Error column for details.');
    //                 }
    //             } else {
    //                 this.showSuccessToast('Success', `Successfully inserted ${successCount} records!`);
    //             }
    //         })
    //         .catch((error) => {
    //             this.showErrorToast('Error Inserting Contacts', error.body?.message || 'An unexpected error occurred.');
    //         })
    //         .finally(() => {
    //             this.isLoading = false;
    //         });
    // }
    

    toggleAccountIdColumn() {
        this.accountIdIncluded = !this.accountIdIncluded;
        this.setupDataTableColumns(this.columns.map(col => col.fieldName)); // Rebuild columns
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.contactsData = [];
        this.file = null;
        this.fileContents = null;
        this.disableUpload = true;
        this.disableInsert = true;
        this.refreshPage(); // Refresh the page when the modal is closed
    }

    refreshPage() {
        window.location.reload(); // This will refresh the current page
    }

    showErrorToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    // showSuccessToast(title, message) {
    //     this.dispatchEvent(
    //         new ShowToastEvent({
    //             title: title,
    //             message: message,
    //             variant: 'success',
    //             mode: 'dismissable'
    //         })
    //     );
    // }
    secondmodal() {
        this.isSecondModalOpen = true;
    }

    // showMixedToast(title, message) {
    //     this.dispatchEvent(
    //         new ShowToastEvent({
    //             title: title,
    //             message: message,
    //             variant: 'warning',
    //             mode: 'sticky'
    //         })
    //     );
    // }
    closeSecondModal(){
        this.contact_Insert_count = 0;
        this.contact_Total_count = 0;
        this.contact_Ex_count = 0;
        this.contact_Error_count = 0;
        this.campaignmember_insert_count= 0;
        this.campaignmember_ex_count= 0;
        // this.refreshPage();
        this.isSecondModalOpen = false;

   }
   downloadCsv() {
    if (this.contactsData.length === 0) {
        this.showErrorToast('No Data', 'There is no data to download.');
        return;
    }
   
    let csvContent = "data:text/csv;charset=utf-8,";

    // Mapping object for column name replacements
    const columnReplacements = {
        'Status': '_Status',
        'Validation': '_Validation',
        'Campaign Name': '_Campaign Name',
        'Account Name': '_Account Name'
    };

    // Create CSV header from columns, applying column replacements
    const headers = this.columns
        .filter(col => col.fieldName && col.fieldName !== 'rowNumber' && col.fieldName !== 'statusClass')
        .map(col => columnReplacements[col.label] || col.label) // Replace label if a replacement exists
        .join(",") + "\n";
    csvContent += headers;

    // Create CSV rows from contactsData
    this.contactsData.forEach(row => {
        const rowData = this.columns
            .filter(col => col.fieldName && col.fieldName !== 'rowNumber' && col.fieldName !== 'statusClass')
            .map(col => row[col.fieldName] ? `"${row[col.fieldName]}"` : '') // Add double quotes to escape commas in data
            .join(",");
        csvContent += rowData + "\n";
    });

    // Trigger file download with timestamp
    const now = new Date();

    const day = String(now.getDate()).padStart(2, '0');    
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const year = String(now.getFullYear()).slice(2);       
    const hours = String(now.getHours()).padStart(2, '0'); 
    const minutes = String(now.getMinutes()).padStart(2, '0');

    const formattedDate = `${day}/${month}/${year}_${hours}:${minutes}`;
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `Exported_Report${formattedDate}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

handleMouseOver(){
    this.buttonTitle = 'click to get the Inserted Report'; // Title on hover
}

handleMouseOut(){
    this.buttonTitle = 'Download your file'; // Reset title when not hovering
}

}