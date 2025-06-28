import { LightningElement, api, track } from 'lwc';

const ICON_COLOR_MAPPING = new Map([
    ["white", "default"],
    ["red", "success"],
    ["red", "warning"],
    ["red", "error"],
    ["white", "inverse"],
]);

export default class Star extends LightningElement {
   // @api rating = 0;
    @api totalStars = 5;
    @api size = "large";
    @api filledColor = "red";
    @api unfilledColor = "white";
    @api customFilledUrl;
    @api customUnfilledUrl;
    @api type; // Ensure type is properly defined as an API property
    @api value; // Define value as an API property
    @api name; // Define name as an API property
    @track selectedRating;
    @track stars = new Array();

    connectedCallback() {

      this.selectedRating = this.rating || 0; // Default to 0
    this.totalStars = this.totalStars || 5; // Default to 5 stars
    this.generateStars();
    }
generateStars() {
        this.stars = [];
        for (let i = 0; i < this.totalStars; ++i) {
            if (i < this.selectedRating) {
                this.stars.push(
                    {
                        Index: i,
                        State: ICON_COLOR_MAPPING.get(this.filledColor),
                        CustomUrl: this.customFilledUrl
                    }
                );
            } else {
                this.stars.push(
                    {
                        Index: i,
                        State: ICON_COLOR_MAPPING.get(this.unfilledColor),
                        CustomUrl: this.customUnfilledUrl
                    }
                );
            }
        }
    }

    handleRatingHover(event) {
        this.reRenderStars(1 + +event.target.getAttribute('data-id'));
    }

    handleRatingHoverOut() {
        this.reRenderStars(this.selectedRating);
    }

    handleRatingClick(event) {
    const clickedIndex = +event.target.getAttribute('data-id');
    this.selectedRating = (this.selectedRating === clickedIndex + 1) ? 0 : clickedIndex + 1; // Toggle selection/deselection
    this.reRenderStars(); // Update the UI
    const selectedEvent = new CustomEvent('ratingclick', { detail: this.selectedRating });
    this.dispatchEvent(selectedEvent);
}


    reRenderStars() {
    this.stars = [];
    for (let i = 0; i < this.totalStars; ++i) {
        this.stars.push({
            Index: i,
            State: i < this.selectedRating 
                ? ICON_COLOR_MAPPING.get(this.filledColor) 
                : ICON_COLOR_MAPPING.get(this.unfilledColor),
            CustomUrl: i < this.selectedRating 
                ? this.customFilledUrl 
                : this.customUnfilledUrl
        });
    }
    this.stars = [...this.stars]; // Refresh the UI
    console.log('Re-rendered stars:', this.stars);
}

@api 
set rating(value) {
    this.selectedRating = value || 0;
    this.reRenderStars();
}

get rating() {
    return this.selectedRating;
}

    // @api
    // resetRating() {
    //     this.selectedRating = 0;
    //     this.reRenderStars(this.selectedRating);
    // }
}