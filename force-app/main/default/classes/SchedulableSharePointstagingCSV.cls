global class SchedulableSharePointstagingCSV implements Schedulable {
    
    String status;
    global SchedulableSharePointstagingCSV(String status){
        this.status = status;
    }
    
    global void execute(SchedulableContext sc){
        database.executeBatch(new SharePointStagingBatchableCSV(status), 500);
    }
}