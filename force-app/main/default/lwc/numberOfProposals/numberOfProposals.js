import { LightningElement, api, track } from 'lwc';
import createProposals from '@salesforce/apex/ProposalController.createProposals';
import getShellsByOpportunity from '@salesforce/apex/ProposalController.getShellsByOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class NumberOfProposals extends  NavigationMixin(LightningElement) {
@api recordId;

@track showTemplate = false;
@track showButton = true;
@track proposalCount;
@track shells = [];
@track selectedShells = [];
@track showShellTable = false;
 @track proposalTables = [];

columns = [
        { label: 'Shell Name', fieldName: 'Name' },
    ];

// connectedCallback() {
//     this.fetchShells();
// }

fetchShells(){
    getShellsByOpportunity({
        opportunityId: this.recordId,
        })

        .then(result => {
            this.shells = result; // assuming you have a `shells` property
            console.log('Shells fetched:', result);

            if (this.shells.length < this.proposalCount) {
                    this.showToast('Error', `Only ${this.shells.length} shells found. You requested ${this.proposalCount}.`, 'error');
                }
                // Initialize proposalTables
                this.proposalTables = [];
                for (let i = 0; i < this.proposalCount; i++) {
                    this.proposalTables.push({
                        id: i + 1,
                        selectedShells: []
                    });
                }
                this.refreshShellTables();

                this.showShellTable = true;
        })
        .catch(error => {
            this.error = error;
            console.error('Error fetching Shells:', error);
        });
}

getShellRows(index) {
    const selectedInOtherProposals = new Set();
    this.proposalTables.forEach((table, i) => {
        if (i !== index) {
            table.selectedShells.forEach(id => selectedInOtherProposals.add(id));
        }
    });

    // Return a copy of shell records with disable info
    return this.shells.map(shell => {
        return {
            ...shell,
            _disabled: selectedInOtherProposals.has(shell.Id)
        };
    });
}

get rowAttributes() {
    return (row) => ({
        disabled: row._disabled
    });
}

refreshShellTables() {
    this.proposalTables = this.proposalTables.map((table, i) => {
        const selectedInOthers = new Set();
        this.proposalTables.forEach((t, j) => {
            if (i !== j) {
                t.selectedShells.forEach(id => selectedInOthers.add(id));
            }
        });

        const shellData = this.shells.map(shell => ({
            ...shell,
            _disabled: selectedInOthers.has(shell.Id)
        }));

        return {
            ...table,
            index: i,
            data: shellData
        };
    });
}

handleClick(){
    this.showTemplate = true;
    this.showButton = false;
    this.showShellTable = false;
}

handleBack(){
    this.showTemplate = false;
    this.showButton = true;
    this.proposalCount = '';
}

handleBack2(){
    this.showTemplate = true;
    this.showShellTable = false;
    this.proposalCount = '';
}

handleNext() {
        if (!this.proposalCount || this.proposalCount <= 0) {
            this.showToast('Error', 'Please enter a valid number.', 'error');
            return;
        }

        // this.showShellTable = true;
        this.fetchShells();
        this.showTemplate = false;
        this.showButton = false;
}

 handleRowSelection(event) {
        const index = event.target.dataset.index;
        const selected = event.detail.selectedRows.map(row => row.Id);
        this.proposalTables[index].selectedShells = selected;
        this.refreshShellTables();
    }

handleInputChange(event){
    this.proposalCount = event.detail.value;
}

hideModalBox() {           
    this.showTemplate = false;
    this.showShellTable = false; 
    this.showButton = true;   
    this.proposalCount = ''; 
    }

handleSubmit(){
    if (!this.proposalCount || this.proposalCount <= 0) {
           
            return;
        }

        createProposals({ 
            opportunityId: this.recordId, 
            numberOfProposals: this.proposalCount 
        })
        .then(() => {
            this.showToast('Success', `${this.proposalCount} proposal(s) created successfully.`, 'success');
            this.navigateToRecordPage();

            this.showButton = true;
            this.showTemplate = false;
            this.proposalCount = null;
            // Show toast if needed
            console.log('Proposals created successfully.');
        })
        .catch(error => {
            this.showToast('Error', error.body?.message || 'An error occurred while creating proposals.', 'error');
            console.error('Error creating proposals:', error);
        });
    }

showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

navigateToRecordPage() {
    this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
}