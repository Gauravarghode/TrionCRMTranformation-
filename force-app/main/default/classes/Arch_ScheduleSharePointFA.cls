public class Arch_ScheduleSharePointFA implements Schedulable {
     String status;
    public Arch_ScheduleSharePointFA(String status){
        this.status = status;
    }
    public void execute(SchedulableContext sc){
        System.abortJob(sc.getTriggerId());
        Datetime now = Datetime.now();
        Datetime nextRun = now.addMinutes(3);
        String cronExp = nextRun.second() + ' ' + nextRun.minute() + ' ' +  now.hour() + ' ' + ' * ' + ' ' + ' * ' + ' ? ' + ' * ';
        System.schedule('Arch_Schedule SharePoint Files & Attachments Upload - '+nextRun.getTime(),cronExp,new Arch_ScheduleSharePointFA(status));
        Arch_SharePointStagingBatchableFA sharePointBatch = New Arch_SharePointStagingBatchableFA(status);
        Database.executeBatch(sharePointBatch);
    }

}