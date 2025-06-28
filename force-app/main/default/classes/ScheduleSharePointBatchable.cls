public class ScheduleSharePointBatchable implements Schedulable {
     String status;
    public ScheduleSharePointBatchable(String status){
        this.status = status;
    }
    public void execute(SchedulableContext sc){
        SharePointStagingBatchable sharePointBatch = New SharePointStagingBatchable(status);
        Database.executeBatch(sharePointBatch);
    }

}