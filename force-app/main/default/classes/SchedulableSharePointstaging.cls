global class SchedulableSharePointstaging implements Schedulable {
    
    String status;
    global SchedulableSharePointstaging(String status){
        this.status = status;
    }
    
    global void execute(SchedulableContext sc){
        database.executeBatch(new SharePointStagingBatchable(status), 500);
    }
}